class AddMapCoordinatesToArmies < ActiveRecord::Migration[7.0]
  # Положение армии на карте «Эпохи перемен» (экран «Карта» в era_native).
  #
  # Армия в городе рисуется от координат поселения (`armies.settlement_id`), а в
  # поле своего места в данных не имела вовсе — поэтому две нормализованные
  # колонки (0..1 от полотна 2881 × 2881), как у `settlements.map_x/map_y`
  # (`docs/map/TZ-karta.md`, § 4.2).
  #
  # Колонки `NULL`-able и без бэкфилла: у армии в городе положение выводится из
  # поселения, у полевой до первого перемещения координат нет — клиент рисует её
  # у столицы своего государства и даёт мастеру «Передвинуть».
  def up
    add_column :armies, :map_x, :float
    add_column :armies, :map_y, :float
  end

  def down
    remove_column :armies, :map_x
    remove_column :armies, :map_y
  end
end
