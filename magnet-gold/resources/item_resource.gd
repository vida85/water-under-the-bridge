class_name ItemResource extends Resource


@export_group("Basic Information")
@export var name: String
@export_multiline("funny item description") var item_description: String
@export var texture: Texture2D

@export_group("Value")
@export var value: float
@export var combo_bonus_value: float
@export var combo_item_id: StringName
@export var combo_item_ids: Array[StringName]
@export var caught_radius: float


func get_total_value(item: Item, inventory_combo_items: Array[Item]) -> float:
	var total: float = 0.0

	for _item: Item in inventory_combo_items:
		if _item.combo_item_id in combo_item_ids:
			total += _item.item_resource.value + _item.item_resource.combo_bonus_value

	total += item.item_resource.value + (item.item_resource.combo_bonus_value if total != 0.0 else 0.0)

	return total
