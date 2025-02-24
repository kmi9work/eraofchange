current_year = 1
GameParameter.create(id: current_year, title: "Текущий год", identificator: "current_year", value: "1", params:
{"state_expenses" => false})
GameParameter.create(title: "Ставка кредита (%)", identificator: "credit_size", value: "20")
GameParameter.create(title: "Срок кредита (лет)", identificator: "credit_term", value: "3")
