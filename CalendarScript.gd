extends Node
# base calendar class
class_name Calendar, "res://Calendar/CalendarNode.svg"
# should it be something like Dates for base class and calendar for visual one?
# I think it is fine as it is, if it becomes messy in the future will change then.

# WARNING: dst (daylight saving time) not supported!

# TODO:
# make a clock - in clock class
# add time selection control
# add duration selection control
# update daylight savings - might be a bit tricky, might need to just leave it for now

# move some functions deeper into subclass, but allow calls from base class?


var selected_date = OS.get_date() setget set_selected_date, get_selected_date
var previous_date = selected_date.duplicate() # need this to not make a reference


func _ready():
	pass
	#print("current date time: ", selected_date)


func _process(_delta):
	pass


################################################################################
############################# SETTERS AND GETTERS ##############################
################################################################################
func set_selected_date(new_date):
	var date_valid = false
	previous_date = selected_date.duplicate()
	selected_date = new_date.duplicate()
	if not _cast_date():
		selected_date = previous_date.duplicate()
		printerr("Cannot set date. Provided date invalid.")
	else:
		_update_weekday()
		date_valid = true
	if has_node('CalendarContainer') and (selected_date.hash() != previous_date.hash()):
		$CalendarContainer.update_visual_calendar()
	emit_signal("date_updated")
	return date_valid
	# Should it return boolean or just the selected date?
	# Prob boolean, but might consider alternatives if necessary


func get_selected_date():
	return selected_date


func set_year(new_year):
	var date_valid = false
	var validation_failed = false
	previous_date = selected_date.duplicate()
	selected_date["year"] = new_year
	if _cast_date_value_to_int("year"):
		if (selected_date["year"] < 1) or (selected_date["year"] > 9999):
			validation_failed = true
			selected_date = previous_date.duplicate()
			printerr("Cannot set year, number out of bounds.")
		#elif selected_date["day"] > get_last_day_of_month():
		#	set_day(get_last_day_of_month())
		else:
			_handle_out_of_bounds_day()
	else:
		validation_failed = true
		selected_date = previous_date.duplicate()
		printerr("Cannot set year. Provided year invalid.")
	
	if not validation_failed:
		if not _cast_date():
			# after moving return to the end, will do this even if already determined to be invalid
			# should be fine though. 
			# It was not fine... added validation_failed to avoid casting previous date
			selected_date = previous_date.duplicate()
			printerr("Cannot set year. new date invalid.")
		else:
			_update_weekday()
			date_valid = true
		
	if has_node('CalendarContainer') and (selected_date.hash() != previous_date.hash()):
		$CalendarContainer.update_visual_calendar()
	emit_signal("date_updated")
	return date_valid

func get_year():
	return selected_date["year"]


func set_month(new_month):
	var date_valid = false
	var validation_failed = false # used to avoid casting date after it was already reset
	previous_date = selected_date.duplicate()
	selected_date["month"] = new_month
	if _cast_date_value_to_int("month"):
		if (selected_date["month"] < 1) or (selected_date["month"] > 12):
			validation_failed = true
			selected_date = previous_date.duplicate()
			printerr("Cannot set month, number out of bounds.")
		else:
			_handle_out_of_bounds_day()
		"""
		if selected_date['month'] < 1:
			selected_date['month'] = 1
		elif selected_date['month'] > 12:
			selected_date['month'] = 12
		"""
		#if selected_date["day"] > get_last_day_of_month():
		#	set_day(get_last_day_of_month())
		# changed to avoid error while updating weekday from out of range date
	else:
		validation_failed = true
		selected_date = previous_date.duplicate() 
		printerr("Cannot set month. Provided month invalid.")
		# fixed: after this, cast_date returns true and sets date to valid
		# only reverse date after failed casting? - or just add another var to check
		# this way avoids unnecessary cast_date if already failed

	if not validation_failed:
		if not _cast_date():
			selected_date = previous_date.duplicate()
			printerr("Cannot set month. New date invalid.")
		else:
			_update_weekday()
			date_valid = true

	if has_node('CalendarContainer') and (selected_date.hash() != previous_date.hash()):
		$CalendarContainer.update_visual_calendar()
	emit_signal("date_updated")
	return date_valid

func get_month():
	return selected_date["month"]


func get_month_name():
	match selected_date["month"]:
		1:
			return "January"
		2:
			return "February"
		3:
			return "March"
		4:
			return "April"
		5:
			return "May"
		6:
			return "June"
		7:
			return "July"
		8:
			return "August"
		9:
			return "September"
		10:
			return "October"
		11:
			return "November"
		12:
			return "December"
		_:
			printerr("Cannot return month name. Month number out of bounds.")


func set_day(new_day):
	var date_valid = false
	previous_date = selected_date.duplicate()
	selected_date["day"] = new_day
	if not _cast_date():
		selected_date = previous_date.duplicate()
		printerr("Cannot set day. New date invalid.")
	else:
		_update_weekday()
		date_valid = true

	if has_node('CalendarContainer') and (selected_date.hash() != previous_date.hash()):
		$CalendarContainer.update_visual_calendar()
	emit_signal("date_updated")
	return date_valid

func get_day():
	return selected_date["day"]


func _handle_out_of_bounds_day():
	if selected_date["day"] > get_last_day_of_month():
		selected_date["day"] = get_last_day_of_month()


func get_last_day_of_month():
	match selected_date["month"]:
		1, 3, 5, 7, 8, 10, 12:
			return 31
		2:
			return 28 + int(_is_leap_year())
		4, 6, 9, 11:
			return 30
		_:
			printerr("Cannot return last day of month. Month number out of bounds.")


func _is_leap_year():
	# suggested code
	if not (selected_date["year"] % 4 == 0):
		return false
	elif not (selected_date["year"] % 100 == 0):
		return true
	elif not (selected_date["year"] % 400 == 0):
		return false
	else:
		return true
	"""
	# my code - bad because deep nesting
	if (year % 4 == 0):
		if (year % 100 == 0):
			if (year % 400 == 0):
				return true
			return false
		else:
			return true
	else:
		return false
	"""


func get_weekday_name():
	match selected_date["weekday"]:
		1:
			return "Monday"
		2:
			return "Tuesday"
		3:
			return "Wednesday"
		4:
			return "Thursday"
		5:
			return "Friday"
		6:
			return "Saturday"
		0:
			return "Sunday"
		_:
			printerr("Cannot return weekday name. Weekday number out of bounds.")


func get_week_number():
	return null # low priority


func _update_weekday():
	var datetime = _get_datetime_from_date(selected_date)
	var unix_time = OS.get_unix_time_from_datetime(datetime)
	datetime = OS.get_datetime_from_unix_time(unix_time)
	selected_date = _get_date_from_datetime(datetime)
	
	"""
	var new_date = selected_date.duplicate()
	var new_datetime = OS.get_unix_time_from_datetime(_get_datetime_from_date(new_date))
	selected_date = previous_date.duplicate()
	var selected_datetime
	#var internal_calendar = Calendar.new() #cant load cause ends up a infinite recursion
	while ((selected_date['day'] != new_date['day']) or (selected_date['month'] != new_date['month'])
			or (selected_date['year'] != new_date['year'])):
		#print('in cycle selected date ', selected_date)
		selected_datetime = OS.get_unix_time_from_datetime(_get_datetime_from_date(selected_date))
		if (selected_datetime > new_datetime):
			back_one_day()
		elif(selected_datetime < new_datetime):
			 # should never be equal due to while condition. But probably better to just check anyway
			# though if I become sure I should prob remove to reduce the amount of ifs
			forward_one_day()
		else:
			printerr('THIS SHOULD NEVER HAPPEN. WHY DID THIS HAPPEN???')
	"""
	# how to know which weekday is the new day?
	# previous_date day minus selected_date date
	# much more difficult for month, but maybe manageable?
	# calculate the number of days between dates
	# same for year
	# (complicated)
	# OR
	# just move back/forward one day until day and month and year are equal, then get that
	# should I have just done that for all functions? Maybe, but not sure it would have been much better
	# how to know if i should move forward or backward?
	# convert previous and new dates to unix seconds, see which is bigger
	# (performance issues with big year changes) - not an issue unless wrongly typed in date
	# OR
	# getunixtime from date then set date from unixtime


func _get_datetime_from_date(date):
	var datetime = OS.get_datetime()
	datetime["year"] = date["year"]
	datetime["month"] = date["month"]
	datetime["day"] = date["day"]
	datetime["weekday"] = date["weekday"]
	datetime["dst"] = date["dst"]
	return datetime
	

func _get_date_from_datetime(datetime):
	var date = OS.get_date()
	date["year"] = datetime["year"]
	date["month"] = datetime["month"]
	date["day"] = datetime["day"]
	date["weekday"] = datetime["weekday"]
	if datetime.has("dst"):
		date["dst"] = datetime["dst"]
	else:
		date["dst"] = null
		# datetime does not have dst if determined by get_datetime_from_unix_time

	return date


func get_text_date(date = selected_date.duplicate()):
	var text = ""
	# order should depend on regional settings. 
	# dictionaries are not ordered, but order does depend on input order?
	# Might be that OS.get_date would order correctly
	for key in date:
		if key == "year" or key == "month":
			text += str(date[key])
			text += "/"
		if key == "day":
			text += str(date[key])
	return text


func back_one_day(): # technically set and get previous day
	if selected_date["day"] > 1:
		selected_date["day"] -= 1
	elif selected_date["month"] > 1:
		selected_date["month"] -= 1
		selected_date["day"] = get_last_day_of_month()
	else:
		selected_date["year"] -= 1
		selected_date["month"] = 12
		selected_date["day"] = 31
		
	if selected_date["weekday"] > 0:
		selected_date["weekday"] -= 1
	else:
		selected_date["weekday"] = 6

	if has_node('CalendarContainer'):
		$CalendarContainer.update_visual_calendar()
	emit_signal("date_updated")
	return selected_date


func forward_one_day(): # technically set and get next day
	if selected_date["day"] < get_last_day_of_month():
		selected_date["day"] += 1
	elif selected_date["month"] < 12:
		selected_date["month"] += 1
		selected_date["day"] = 1
	else:
		selected_date["year"] += 1
		selected_date["month"] = 1
		selected_date["day"] = 1
		
	if selected_date["weekday"] < 6:
		selected_date["weekday"] += 1
	else:
		selected_date["weekday"] = 0
		
	if has_node('CalendarContainer'):
		$CalendarContainer.update_visual_calendar()
	emit_signal("date_updated")
	return selected_date


func back_one_month():
	if selected_date["month"] > 1:
		selected_date["month"] -= 1
	else:
		selected_date["year"] -= 1
		selected_date["month"] = 12
		
	_handle_out_of_bounds_day() #attempt to return same day next previous month
	_update_weekday()

	if has_node('CalendarContainer'):
		$CalendarContainer.update_visual_calendar()
	emit_signal("date_updated")
	return selected_date


func forward_one_month():
	if selected_date["month"] < 12:
		selected_date["month"] += 1
	else:
		selected_date["year"] += 1
		selected_date["month"] = 1
		
	_handle_out_of_bounds_day()
	_update_weekday()
		
	if has_node('CalendarContainer'):
		$CalendarContainer.update_visual_calendar()
	emit_signal("date_updated")
	return selected_date


func back_one_year():
	selected_date["year"] -= 1
		
	_handle_out_of_bounds_day()
	_update_weekday()

	if has_node('CalendarContainer'):
		$CalendarContainer.update_visual_calendar()
	emit_signal("date_updated")
	return selected_date
	
	
func forward_one_year():
	selected_date["year"] += 1
		
	_handle_out_of_bounds_day()
	_update_weekday()

	if has_node('CalendarContainer'):
		$CalendarContainer.update_visual_calendar()
	emit_signal("date_updated")
	return selected_date


# dont think i need these
#func get_previous_month_firstday_date(date):
	#should it be last day? would let me use it in get_prev_day
	# probably doesnt matter, get_prev_day code is ok already
#	pass
#func get_next_month_firstday_date(date):
#	pass # why did i want this? for next month jump?
################################################################################
################################################################################


################################################################################
########################### CASTING AND VALIDATION #############################
################################################################################
func _cast_date():
	var date_valid = false
	if selected_date.keys() != OS.get_date().keys():
		printerr("Date not valid, wrong dictionary format")
		return date_valid
	"""
	if typeof(selected_date['year']) != TYPE_INT:
		printerr('Date not valid, year value not integer')
	elif typeof(selected_date['month']) != TYPE_INT:
		printerr('Date not valid, month value not integer')
	elif typeof(selected_date['day']) != TYPE_INT:
		printerr('Date not valid, day value not integer')
	elif typeof(selected_date['weekday']) != TYPE_INT:
		printerr('Date not valid, weekday value not integer')
	elif typeof(selected_date['dst']) != TYPE_BOOL:
		printerr('Date not valid, daylight saving time value not boolean')
	"""
	if not _cast_date_values_to_int():
		printerr("Casting date values to integers failed")
	elif not _cast_dst_to_bool():
		printerr("Casting daylight saving time value to boolean failed")
	elif (selected_date["year"] < 1) or (selected_date["year"] > 9999):
		printerr("Date not valid, year number out of bounds.")
	elif (selected_date["month"] < 1) or (selected_date["month"] > 12):
		printerr("Date not valid, month number out of bounds.")
	elif (selected_date["day"] < 1) or (selected_date["day"] > get_last_day_of_month()):
		printerr("Date not valid, day number out of bounds.")
	elif (selected_date["weekday"] < 0) or (selected_date["weekday"] > 6):
		printerr("Date not valid, weekday number out of bounds.")
	else:
		date_valid = true
	return date_valid


func _cast_date_values_to_int():
	# entering wrong type info should roll back rather than crash or result in unexpected behavior
	if (_cast_date_value_to_int("year") and _cast_date_value_to_int("month") and
		_cast_date_value_to_int("day") and _cast_date_value_to_int("weekday")):
		return true
	else:
		return false
	# should I just cast to int and not worry about it?
	# might still be issues, prob easier to just do it properly. Will make later debugging easier.
	# yeah default returns 0 for poor casts, which would get caught later, but with a generic out of bounds error message


func _cast_date_value_to_int(date_key):
	var data_type_valid = false
	match typeof(selected_date[date_key]):
		TYPE_STRING:
			if selected_date[date_key].is_valid_integer():
				selected_date[date_key] = int(selected_date[date_key])
				data_type_valid = true
			elif selected_date[date_key].is_valid_float():
				selected_date[date_key] = int(selected_date[date_key])
				data_type_valid = true
			elif date_key == "month":
				if _cast_month_from_string():
					data_type_valid = true
			else:
				printerr("Cannot convert %s to an int. Given string %s is not an int or float." % [date_key, selected_date[date_key]])
		TYPE_INT:
			data_type_valid = true
		TYPE_REAL:
			selected_date[date_key] = int(selected_date[date_key])
			data_type_valid = true
		_:
			printerr("Cannot convert %s to an int. Unrecognized type of data in value.", date_key)
	return data_type_valid


func _cast_month_from_string():
	var valid_month_name = true
	if typeof(selected_date["month"]) == TYPE_STRING:
		match selected_date["month"].to_lower():
			"january", "jan":
				selected_date["month"] = 1
			"february", "feb":
				selected_date["month"] = 2
			"march", "mar":
				selected_date["month"] = 3
			"april", "apr":
				selected_date["month"] = 4
			"may":
				selected_date["month"] = 5
			"june", "jun":
				selected_date["month"] = 6
			"july", "jul":
				selected_date["month"] = 7
			"august", "aug":
				selected_date["month"] = 8
			"september", "sep":
				selected_date["month"] = 9
			"october", "oct":
				selected_date["month"] = 10
			"november", "nov":
				selected_date["month"] = 11
			"december", "dec":
				selected_date["month"] = 12
			_:
				valid_month_name = false
				printerr("Cannot convert month to int, unrecognized month name.")
	else:
		valid_month_name = false
		printerr("Cannot convert month to int, value not a string.")
			
	return valid_month_name


func _cast_dst_to_bool():
	var data_type_valid = false
	if selected_date["dst"] == null:
		data_type_valid = true
	else:
		match typeof(selected_date["dst"]):
			TYPE_BOOL:
				data_type_valid = true
			TYPE_STRING:
				if selected_date["dst"].is_valid_integer():
					var dst_bool = _cast_int_to_bool(int(selected_date["dst"]))
					if dst_bool != null:
						selected_date["dst"] = dst_bool
						data_type_valid = true
					else:
						printerr("Cannot convert dst to a boolean. Unrecognized number in string value.")
				else:
					match selected_date["dst"]:
						"true", "True":
							selected_date["dst"] = true
							data_type_valid = true
						"false", "False":
							selected_date["dst"] = false
							data_type_valid = true
						_:
							printerr("Cannot convert dst to a boolean. Unrecognized string in value.")
			TYPE_INT:
				var dst_bool = _cast_int_to_bool(selected_date["dst"])
				if dst_bool != null:
					selected_date["dst"] = dst_bool
					data_type_valid = true
				else:
					printerr("Cannot convert dst to a boolean. Unrecognized integer in value.")
			TYPE_REAL:
				printerr("Cannot convert dst to a boolean. Float values are not valid.")
			_:
				printerr("Cannot convert dst to a boolean. Unrecognized data type in value.")
	return data_type_valid


func _cast_int_to_bool(number:int):
	match number:
		0:
			return false
		1:
			return true
		_:
			printerr("Unrecognized number in value. Cannot convert to boolean")
			return null
################################################################################
################################################################################


################################################################################
############################## VISUAL CALENDAR #################################
################################################################################
func show_calendar():
	#$CalendarContainer.update_visual_calendar() # should be redundant
	$CalendarContainer.show()


func hide_calendar():
	$CalendarContainer.hide()


func move_calendar(new_position = Vector2(0,0)):
	if new_position != Vector2(0,0):
		$CalendarContainer.rect_position = new_position


#func get_calendar_visible():
#	return $CalendarContainer.visible
################################################################################
################################################################################


################################################################################
############################### CONTROL UPDATE #################################
################################################################################
signal date_updated

#func update_controls(scene_tree):
# iterate through the whole tree
#	pass

#func update_group_controls(group_name):
# instead of iterating through all nodes, just getting the ones in a group
#	for control in get_nodes_in_group(group_name):
#		if control.get_class() == "LineEdit":
#			control.text = 
#	pass # seems like too much work for little gain
	# also need to setup groups for each field type

################################################################################
################################################################################
