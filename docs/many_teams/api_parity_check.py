#!/usr/bin/env python3
# Проверка контрактов API после перехода на «несколько команд» (ТЗ № 1, § 12).
# Запускается против локально поднятого сервера разработки.
import json
import os
import sys
import urllib.error
import urllib.request
import http.cookiejar

BASE = os.environ.get("ERA_API_BASE", "http://127.0.0.1:3100")
if len(sys.argv) > 1:
    arg = sys.argv[1]
    BASE = arg if arg.startswith("http") else f"http://127.0.0.1:{arg}"
jar = http.cookiejar.CookieJar()
opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(jar))

failures = []


def request(path, method="GET", data=None):
    url = BASE + path
    body = None
    headers = {"Accept": "application/json"}
    if data is not None:
        body = json.dumps(data).encode()
        headers["Content-Type"] = "application/json"
    req = urllib.request.Request(url, data=body, headers=headers, method=method)
    try:
        with opener.open(req) as resp:
            raw = resp.read().decode()
            return resp.status, raw
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()


def get_json(path):
    status, raw = request(path)
    try:
        return status, json.loads(raw)
    except Exception:
        return status, {"__raw__": raw[:400]}


def check(name, condition, detail=""):
    mark = "OK  " if condition else "FAIL"
    if not condition:
        failures.append(f"{name}: {detail}")
    print(f"{mark} {name} {detail}")
    return condition


print("=== 1. Текущее государство по умолчанию ===")
status, current = get_json("/current_country.json")
check("GET /current_country.json", status == 200 and current.get("id") == 1,
      f"http={status} id={current.get('id')} name={current.get('name')}")
rus_id = current.get("id")

print("=== 2. Регионы своего государства (Русь) ===")
status, regions = get_json("/regions.json")
check("GET /regions.json — регионы Руси", status == 200 and len(regions) == 4,
      f"http={status} регионов={len(regions)}")
rus_region_ids = [r["id"] for r in regions]

print("=== 3. Фильтры списка государств ===")
status, foreign = get_json("/countries.json?foreign=1")
ok = status == 200 and isinstance(foreign, list) and rus_id not in [c["id"] for c in foreign]
check("GET /countries.json?foreign=1 — без Руси", ok, f"http={status} ids={[c['id'] for c in foreign] if isinstance(foreign, list) else foreign}")
status, all_countries = get_json("/countries.json")
check("GET /countries.json — все государства", status == 200 and len(all_countries) >= 12,
      f"http={status} стран={len(all_countries) if isinstance(all_countries, list) else all_countries}")

print("=== 4. Технологии в разрезе государства ===")
status, technologies = get_json("/technologies.json")
first = technologies[0] if isinstance(technologies, list) and technologies else {}
technology_count = len(technologies) if isinstance(technologies, list) else 0
check("GET /technologies.json — список технологий", status == 200 and technology_count > 0,
      f"http={status} технологий={technology_count}")
check("is_open у Руси — все технологии закрыты, как до перехода",
      [t["is_open"] for t in technologies] == [0] * technology_count,
      f"is_open={[t['is_open'] for t in technologies] if isinstance(technologies, list) else ''}")
items = first.get("technology_items", [])
check("technology_items содержат факты по государствам",
      bool(items) and all(i["country_id"] is not None for i in items),
      f"строк={len(items)} country_id={sorted({i['country_id'] for i in items})}")

print("=== 5. Армии: свои и зарубежные ===")
status, own_armies = get_json("/armies.json?foreign=0")
check("GET /armies.json?foreign=0 — армии Руси", status == 200 and isinstance(own_armies, list),
      f"http={status} армий={len(own_armies) if isinstance(own_armies, list) else own_armies}")
status, foreign_armies = get_json("/armies.json?foreign=1")
check("GET /armies.json?foreign=1 — без армий Руси",
      status == 200 and all(a.get("country_id") != rus_id for a in foreign_armies),
      f"http={status} армий={len(foreign_armies) if isinstance(foreign_armies, list) else foreign_armies}")

print("=== 6. Игроки и совет ===")
status, players = get_json("/players.json")
check("GET /players.json — игроки Руси", status == 200 and isinstance(players, list) and len(players) > 0,
      f"http={status} игроков={len(players) if isinstance(players, list) else players}")
if isinstance(players, list) and players:
    p = players[0]
    check("игрок содержит country_id/income/influence",
          p.get("country_id") == rus_id and "income" in p and "influence" in p,
          f"country_id={p.get('country_id')} ключи={sorted(list(p.keys())[:12])}")
status, jobs = get_json("/jobs.json")
council_ok = isinstance(jobs, list) and all("player_ids" in j for j in jobs)
check("GET /jobs.json — держатели должностей по государству", status == 200 and council_ok,
      f"http={status} должностей={len(jobs) if isinstance(jobs, list) else jobs}")

print("=== 7. Расходы государства независимы ===")
status, gp = get_json("/game_parameters.json")
cy = [g for g in gp if g.get("identificator") == "current_year"] if isinstance(gp, list) else []
check("GET /game_parameters.json — current_year с разрезом по государствам",
      status == 200 and bool(cy) and "state_expenses_by_country" in cy[0].get("params", {}),
      f"http={status} params={list(cy[0]['params'].keys())[:8] if cy else gp}")

litva_id = next((c["id"] for c in all_countries if c["id"] != rus_id), None)
status, paid = request(f"/game_parameters/pay_state_expenses.json?country_id={litva_id}", method="PATCH")
check(f"Оплата расходов для государства {litva_id}", status in (200, 204), f"http={status} ответ={paid}")
status, gp = get_json("/game_parameters.json")
cy = [g for g in gp if g.get("identificator") == "current_year"][0]
by_country = cy["params"]["state_expenses_by_country"]
check("разрез расходов ключуется по государству",
      isinstance(by_country, dict) and str(rus_id) in by_country and str(litva_id) in by_country,
      f"ключи={sorted(by_country.keys()) if isinstance(by_country, dict) else by_country}")
check(f"расходы государства {litva_id} оплачены, у Руси — нет",
      by_country.get(str(litva_id)) is True and by_country.get(str(rus_id)) is False,
      f"Русь={by_country.get(str(rus_id))} государство{litva_id}={by_country.get(str(litva_id))}")
check("параметр state_expenses текущего государства совпадает с разрезом",
      cy["params"].get("state_expenses") == by_country.get(str(rus_id)),
      f"state_expenses={cy['params'].get('state_expenses')}")

print("=== 8. Переключение текущего государства ===")
status, switched = get_json(f"/login_country/{litva_id}.json")
check(f"GET /login_country/{litva_id}.json", status == 200, f"http={status} {switched}")
status, current = get_json("/current_country.json")
check("текущее государство переключилось", current.get("id") == litva_id, f"id={current.get('id')}")
status, regions_litva = get_json("/regions.json")
check("регионы этого государства (другие)", status == 200 and set(r["id"] for r in regions_litva) != set(rus_region_ids),
      f"регионов={len(regions_litva)}")
status, foreign_litva = get_json("/countries.json?foreign=1")
check("Русь в списке зарубежных", rus_id in [c["id"] for c in foreign_litva],
      f"ids={[c['id'] for c in foreign_litva][:6]}...")
status, technologies_litva = get_json("/technologies.json")
check("технологии того же государства, факты по нему",
      status == 200 and technologies_litva[0]["country_id"] == litva_id,
      f"country_id={technologies_litva[0]['country_id']}")
status, jobs_litva = get_json("/jobs.json")
check("должностей у нового государства нет",
      status == 200 and all(j["player_ids"] == [] for j in jobs_litva),
      f"занятых={[j['name'] for j in jobs_litva if j['player_ids']]}")

print("=== 9. Вассальные чек-листы ===")
status, checklists = get_json("/vassals_and_robbers/checklists.json")
ok = status == 200 and isinstance(checklists, list)
check("GET /vassals_and_robbers/checklists.json", ok,
      f"http={status} чек-листов={len(checklists) if isinstance(checklists, list) else checklists}")
if ok and checklists:
    first_checklist = checklists[0]
    check("чек-лист знает своё государство-сюзерена и вассала",
          "sovereign_country_id" in first_checklist and "vassal_country" in first_checklist,
          f"сюзерен={first_checklist.get('sovereign_country_id')} вассал={first_checklist.get('vassal_country', {}).get('name')}")

print("=== 10. Общественный порядок и места для строений ===")
status, region = get_json("/regions/1.json")
check("GET /regions/1.json — порядок в разрезе государства региона",
      status == 200 and isinstance(region, dict) and any("po" in k or "public_order" in k for k in region.keys()),
      f"http={status} ключи={sorted(region.keys())[:14] if isinstance(region, dict) else region}")
status, places = get_json("/plant_places/available_places.json")
check("GET /plant_places/available_places.json", status == 200, f"http={status}")

print("=== 11. Этап 2: матрица отношений Дашборда ===")
status, matrix = get_json(f"/countries/relations_matrix.json?country_ids={litva_id}")
ok = status == 200 and isinstance(matrix, dict) and matrix.get("country_ids") == [litva_id]
check("GET /countries/relations_matrix.json?country_ids=<id>", ok,
      f"http={status} country_ids={matrix.get('country_ids') if isinstance(matrix, dict) else matrix}")
rows = matrix.get("rows", []) if isinstance(matrix, dict) else []
check("матрица: строка = пара (A, B) со всеми полями отношений",
      bool(rows) and all(r.get("partner") and r.get("country") for r in rows)
      and all(r["country"]["relation_partner_id"] == r["partner"]["id"] for r in rows),
      f"строк={len(rows)}")
check("матрица: в строке есть значение, торговые очки и правки",
      bool(rows) and all(k in rows[0]["country"] for k in ("relations", "relation_points", "relation_items")),
      f"ключи={sorted(rows[0]['country'].keys())[:12] if rows else []}")
status, matrix_two = get_json(f"/countries/relations_matrix.json?country_ids={rus_id},{litva_id}")
rows_two = matrix_two.get("rows", []) if isinstance(matrix_two, dict) else []
pairs_two = [(r["partner"]["id"], r["country"]["id"]) for r in rows_two]
check("матрица: пары между отмеченными не показываются и не дублируются",
      status == 200 and len(pairs_two) == len(set(pairs_two))
      and all(not (a in (rus_id, litva_id) and b in (rus_id, litva_id)) for a, b in pairs_two),
      f"строк={len(pairs_two)}")

print("=== 12. Этап 2: настройки вассальных доходов по сюзеренам ===")
status, vassal_settings = get_json(f"/game_parameters/get_vassalage_settings.json?country_id={rus_id}")
check("GET /game_parameters/get_vassalage_settings.json?country_id=",
      status == 200 and isinstance(vassal_settings, dict) and "vassal_incomes" in vassal_settings
      and vassal_settings.get("country_id") == rus_id,
      f"http={status} country_id={vassal_settings.get('country_id') if isinstance(vassal_settings, dict) else vassal_settings}")

print("=== 13. Этап 2: игроки государства и разбивка дохода ===")
status, players_rus = get_json(f"/players.json?country_id={rus_id}&player_type_id=2")
check("GET /players.json?country_id=&player_type_id=2 — знать государства",
      status == 200 and isinstance(players_rus, list)
      and all(p.get("country_id") == rus_id for p in players_rus),
      f"http={status} игроков={len(players_rus) if isinstance(players_rus, list) else players_rus}")
if isinstance(players_rus, list) and players_rus:
    pid = players_rus[0]["id"]
    status, breakdown = get_json(f"/players/{pid}/income_breakdown.json?country_id={rus_id}")
    check("GET /players/:id/income_breakdown.json?country_id= — разбивка по государству",
          status == 200 and isinstance(breakdown, dict) and "components" in breakdown,
          f"http={status} components={breakdown.get('components') if isinstance(breakdown, dict) else breakdown}")

print("=== 14. Этап 2: должности и политдействия в разрезе государства ===")
status, jobs_rus = get_json(f"/jobs.json?nobles=1&country_id={rus_id}")
check("GET /jobs.json?nobles=1&country_id=", status == 200 and isinstance(jobs_rus, list)
      and all(j.get("country_id") == rus_id for j in jobs_rus),
      f"http={status} должностей={len(jobs_rus) if isinstance(jobs_rus, list) else jobs_rus}")
status, pa = get_json(f"/political_actions.json?country_id={rus_id}")
check("GET /political_actions.json?country_id=", status == 200 and isinstance(pa, list),
      f"http={status} действий={len(pa) if isinstance(pa, list) else pa}")

print("=== 15. Этап 2: результаты по государству и году ===")
status, bundle = get_json(f"/game_parameters/screen_bundle?country_id={rus_id}")
check("GET /game_parameters/screen_bundle?country_id= — живой расчёт",
      status == 200 and isinstance(bundle, dict) and bundle.get("country_id") == rus_id
      and bundle.get("source") == "live",
      f"http={status} country_id={bundle.get('country_id') if isinstance(bundle, dict) else bundle} source={bundle.get('source') if isinstance(bundle, dict) else ''}")

print()
if failures:
    print(f"ПРОВАЛЕНО {len(failures)}:")
    for f in failures:
        print("  - " + f)
    sys.exit(1)
print("Все проверки API пройдены")
