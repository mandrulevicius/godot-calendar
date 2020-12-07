extends PanelContainer


onready var year_textbox = $VBoxContainer/VBoxContainer/HBoxContainer2/YearVBoxContainer/YearSpinBox.get_line_edit()
onready var month_textbox = $VBoxContainer/VBoxContainer/HBoxContainer2/MonthVBoxContainer2/MonthSpinBox.get_line_edit()
onready var day_textbox = $VBoxContainer/VBoxContainer/HBoxContainer2/DayVBoxContainer3/DaySpinBox.get_line_edit()

# process variables
var dragging = false
var initial_mouse_position
var initial_note_position = self.rect_position


func _ready():
	year_textbox.connect('text_entered', self, '_on_year_textbox_text_entered')
	month_textbox.connect('text_entered', self, '_on_month_textbox_text_entered')
	day_textbox.connect('text_entered', self, '_on_day_textbox_text_entered')
	update_visual_calendar()


func _process(_delta):
	if dragging:
		var mousepos = get_viewport().get_mouse_position()
		self.rect_position = mousepos - initial_mouse_position + initial_note_position


func _on_CalendarContainer_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			dragging = !dragging
			initial_mouse_position = get_viewport().get_mouse_position()
			initial_note_position = self.rect_position
		elif event.button_index == BUTTON_LEFT and !event.pressed:
			dragging = !dragging
		
		
	# basic mobile
	elif event is InputEventScreenTouch:
		if event.pressed and event.get_index() == 0:
			self.position = event.get_position()


func update_visual_calendar():
	#check if not equal?
	# updating values in spinboxes automatically calls update
	# Fixed with equal value checks
	$VBoxContainer/VBoxContainer/HBoxContainer/HBoxContainer/CurrentDateButton.text = get_parent().get_text_date(OS.get_date())
	$VBoxContainer/VBoxContainer/HBoxContainer/HBoxContainer/DateLabel.text = get_parent().get_text_date()
	year_textbox.set_text(str(get_parent().get_year()))
	month_textbox.set_text(str(get_parent().get_month()))
	day_textbox.set_text(str(get_parent().get_day()))
	# is this enough? seems so
	
	#$VBoxContainer/VBoxContainer/HBoxContainer2/YearVBoxContainer/YearSpinBox.apply()
	#$VBoxContainer/VBoxContainer/HBoxContainer2/YearVBoxContainer/YearSpinBox.value = get_parent().get_year()
	#$VBoxContainer/VBoxContainer/HBoxContainer2/MonthVBoxContainer2/MonthSpinBox.value = get_parent().get_month()
	#$VBoxContainer/VBoxContainer/HBoxContainer2/MonthVBoxContainer2/MonthSpinBox.set_value(get_parent().get_month())
	#$VBoxContainer/VBoxContainer/HBoxContainer2/MonthVBoxContainer2/MonthSpinBox.get_line_edit().set_text(str(get_parent().get_month()))
	#$VBoxContainer/VBoxContainer/HBoxContainer2/MonthVBoxContainer2/MonthSpinBox.apply() # doesnt apply if old value same?
	#$VBoxContainer/VBoxContainer/HBoxContainer2/DayVBoxContainer3/DaySpinBox.value = get_parent().get_day()
	$VBoxContainer/VBoxContainer/HBoxContainer2/WeekdayLabel.text = get_parent().get_weekday_name()
	$VBoxContainer/VBoxContainer/HBoxContainer4/MonthNameLabel.text = get_parent().get_month_name()
	$VBoxContainer/GridCalendarContainer.update_grid_calendar(get_parent().get_selected_date())


func update():
	pass
# to decide how to do this, search internet for best practice of moving data
# should i create a new selected_date variable? but still will need to update base calendar

# I guess I should just use calendar setters getters to make sure validation gets done?


func _on_YearSpinBox_value_changed(value):
	if get_parent().get_year() != value:
		get_parent().set_year(value)
	#update_visual_calendar()


func _on_year_textbox_text_entered(new_text):
	if not get_parent().set_year(new_text):
		year_textbox.set_text(str(get_parent().get_year()))
		$VBoxContainer/VBoxContainer/HBoxContainer2/YearVBoxContainer/YearSpinBox.set_value(get_parent().get_year())


func _on_MonthSpinBox_value_changed(value):
	if get_parent().get_month() != value:
		get_parent().set_month(value)


func _on_month_textbox_text_entered(new_text):
	if not get_parent().set_month(new_text):
		month_textbox.set_text(str(get_parent().get_month()))
		$VBoxContainer/VBoxContainer/HBoxContainer2/MonthVBoxContainer2/MonthSpinBox.set_value(get_parent().get_month())

func _on_DaySpinBox_value_changed(value):
	if get_parent().get_day() != value:
		if not get_parent().set_day(value):
			$VBoxContainer/VBoxContainer/HBoxContainer2/DayVBoxContainer3/DaySpinBox.value = get_parent().get_day()
			# is this redundant? should probably just do everything on textbox
			# textbox doesnt trigger updates unless enter is pressed, so need both.
			# however, if int+text is entered, textbox validates first, reverts, but then spinbox cuts of text, and validates only int
			# result: date set to new int without text, but also errors printed


func _on_day_textbox_text_entered(new_text):
	if not get_parent().set_day(new_text):
		day_textbox.set_text(str(get_parent().get_day()))
		$VBoxContainer/VBoxContainer/HBoxContainer2/DayVBoxContainer3/DaySpinBox.set_value(get_parent().get_day())
		# can I make this call a bit more, umm, elegant?


func _on_BackDayButton_button_up():
	get_parent().back_one_day()


func _on_ForwardDayButton_button_up():
	get_parent().forward_one_day()


func _on_CurrentDateButton_button_up():
	get_parent().set_selected_date(OS.get_date())


func _on_grid_day_button_up(button_name):
	var button_node = get_node("VBoxContainer/GridCalendarContainer/" + button_name)
	var grid_container_node = button_node.get_parent()
	#var new_date = get_parent().get_selected_date().duplicate()
	#new_date["day"] = int(button_node.text)
	var new_day = button_node.text
	if button_node in get_tree().get_nodes_in_group(grid_container_node.month_groups[0]):
		get_parent().back_one_month()
	elif button_node in get_tree().get_nodes_in_group(grid_container_node.month_groups[2]):
		get_parent().forward_one_month()
	get_parent().set_day(new_day)
	#get_parent().set_selected_date(new_date)


func _on_BackMonthButton_button_up():
	get_parent().back_one_month()


func _on_ForwardMonthButton_button_up():
	get_parent().forward_one_month()


func _on_BackYearButton_button_up():
	get_parent().back_one_year()


func _on_ForwardYearButton_button_up():
	get_parent().forward_one_year()



func _on_CloseButton_button_up():
	self.hide()
