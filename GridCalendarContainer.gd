extends GridContainer

const WHITE = Color(1, 1, 1)
const GREY = Color(0.5, 0.5, 0.5)
const GREEN = Color(0, 1, 0)
const DARK_GREEN = Color(0, 0.5, 0)

const DEFAULT = "Default"
const HIGHLIGHT = "Highlight"

const DEFAULT_THEME = preload("res://Calendar/Default_Theme.tres")
const EDITOR_THEME = preload("res://Calendar/Editor_Theme.tres")

const HIGHLIGHTED_STYLEBOX = preload("res://Calendar/StyleboxFlat_Highlighted.tres")


var month_groups = [str(self) + "previous_month", str(self) + "active_month", str(self) + "next_month"]

# var day_button_group = ButtonGroup.new() no way to toggle button through script


func _ready():
	for button_node in get_children():
		if button_node is Button:
			button_node.connect("button_up", get_parent().get_parent(), "_on_grid_day_button_up", [button_node.name])
			# how to pass actual value of text during signal emit?

#func _process(delta):
#	pass


func update_grid_calendar(date = OS.get_date()):
	#print("updating with date ", date)
	# avoid update if same month? - still might need to update highlight
	var calendar = Calendar.new()
	calendar.set_selected_date(date.duplicate())
	var selected_month = calendar.get_month()
	while calendar.get_day() > 1:
		calendar.back_one_day()
	#print("first day of month ", calendar.get_selected_date())
	while calendar.get_selected_date()["weekday"] != 1:
		calendar.back_one_day()
	#print("first monday ", calendar.get_selected_date())
	var week_no = 1
	var end_of_month = false
	var button_node
	var day_color = GREY
	var current_group = month_groups[0]
	for group in month_groups:
		for node in get_tree().get_nodes_in_group(group):
			node.remove_from_group(group)
	
	# change logic to update during initial search for first day?
	# then go back to selected date, and iterate forward
	# Fine for now
	while not end_of_month:
		for weekday_no in range(1, 8):
			button_node = get_node('Week%sButton%s' % [week_no, weekday_no])
			button_node.set_text(str(calendar.get_day()))
			#button_node.set_toggle_mode(true)
			#button_node.set_button_group(day_button_group)
			if calendar.get_day() == 1:
				if current_group == month_groups[0]:
					day_color = WHITE
					current_group = month_groups[1]
				elif current_group == month_groups[1]:
					day_color = GREY
					current_group = month_groups[2]
			button_node.add_to_group(current_group)
			if calendar.get_selected_date().hash() == OS.get_date().hash():
				if current_group == month_groups[1]:
					set_button_font_color(button_node, GREEN)
				else:
					set_button_font_color(button_node, DARK_GREEN)
			else:
				set_button_font_color(button_node, day_color)
				
			button_node.set_theme(EDITOR_THEME)
				
			if calendar.get_selected_date().hash() == date.hash():
				#button_node.set_disabled(true)
				set_button_style(button_node, HIGHLIGHT)
			else:
				#button_node.set_disabled(false)
				set_button_style(button_node, DEFAULT)
				
				
			calendar.forward_one_day()
		if selected_month != calendar.get_month():
			end_of_month = true
		week_no += 1
			
	hide_grid_calendar_rows()
	for row_no in range(1, week_no):
		show_grid_calendar_row(row_no)
	
	# do i need to clear the calendar object here? should clear itself right?
	# how to check? look for orphaned nodes?
	# call function a thousand times, see if after there is any memory increase
	# there is, of a few megs, and also thousand of orphaned nodes.
	calendar.queue_free()


func set_button_font_color(button_node: Button, color):
	button_node.set('custom_colors/font_color_disabled', color)
	button_node.set('custom_colors/font_color', color)
	button_node.set('custom_colors/font_color_hover', color)
	button_node.set('custom_colors/font_color_pressed', color)


func set_button_style(button_node: Button, style):
	#var normal_stylebox = button_node.get_stylebox('normal',"Button") #reference, updating this updates all places where used
	#var current_theme
	if style == DEFAULT:
		button_node.set('custom_styles/hover', null)
		button_node.set('custom_styles/pressed', null)
		button_node.set('custom_styles/focused', null)
		button_node.set('custom_styles/disabled', null)
		button_node.set('custom_styles/normal', null)
		#normal_stylebox.set_border_width_all(0)
	elif style == HIGHLIGHT:
		button_node.set('custom_styles/hover', null)
		button_node.set('custom_styles/pressed', null)
		button_node.set('custom_styles/focused', null)
		button_node.set('custom_styles/disabled', null)
		button_node.set('custom_styles/normal', HIGHLIGHTED_STYLEBOX)
		#current_theme = button_node.get_theme()
		#print("theme ", current_theme)
		#print("list ", current_theme.get_stylebox_list("Button"))
		#print("types ", current_theme.get_stylebox_types())
		#normal_stylebox = button_node.get_stylebox('normal',"Button")
		#print("stylebox ", normal_stylebox)
		#normal_stylebox.set_border_width_all(1)
		#normal_stylebox.set_border_color(DARK_GREEN)
		#print("stylebox border ", normal_stylebox.get_border_width(MARGIN_BOTTOM))
		#current_theme.set_stylebox('normal', "Button", normal_stylebox)
		#button_node.set_theme(current_theme)
		#button_node.set('custom_styles/normal', normal_stylebox)
		#button_node.set_stylebox(normal_stylebox)


func hide_grid_calendar_rows():
	for row_no in range(1,7):
		get_node("Week%sLabel" % row_no).set_visible(false)
		for button_no in range(1,8):
			get_node("Week%sButton%s" % [row_no, button_no]).set_visible(false)
	
	
func show_grid_calendar_row(row_no):
	var node_name = "Week%sLabel" % row_no
	get_node(node_name).set_visible(true)
	for button_no in range(1, 8):
		node_name = "Week%sButton%s" % [row_no, button_no]
		get_node(node_name).set_visible(true)
