func _broadcast_turn():
    # Check if turn_order is empty to avoid errors
    if turn_order.size() == 0:
        return  # Avoid processing if no characters are alive
    
    # Your existing code for broadcasting the turn
    var turn_index = 0
    var current_turn = turn_order[turn_index % turn_order.size()]  # Use modulo to wrap the index
    # Logic to handle the current turn
