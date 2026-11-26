-- quantity can never exceed the item's stack cap
USE java_knight_realms;

DELIMITER //

CREATE TRIGGER trg_inventory_max_stack_insert
BEFORE INSERT ON character_inventory
FOR EACH ROW
BEGIN
    IF NEW.quantity > (SELECT max_stack FROM items WHERE item_id = NEW.item_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'quantity exceeds items.max_stack';
    END IF;
END//

CREATE TRIGGER trg_inventory_max_stack_update
BEFORE UPDATE ON character_inventory
FOR EACH ROW
BEGIN
    IF NEW.quantity > (SELECT max_stack FROM items WHERE item_id = NEW.item_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'quantity exceeds items.max_stack';
    END IF;
END//

DELIMITER ;
