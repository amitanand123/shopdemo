
# noinspection SqlWithoutWhere
UPDATE customer SET
    `email` = CONCAT(MD5(`email`), '@novodaily.com'),
    `first_name` = MD5(`first_name`),
    `last_name` = MD5(`last_name`),
    `remote_address` = '127.0.0.1'
;


# noinspection SqlWithoutWhere
UPDATE customer_address SET
    `company` = MD5(`company`),
    `first_name` = MD5(`first_name`),
    `last_name` = MD5(`last_name`),
    `street` = MD5(`street`),
    `phone_number` = MD5(`phone_number`)
;


# noinspection SqlWithoutWhere
UPDATE order_customer SET
    `email` = CONCAT(MD5(`email`), '@novodaily.com'),
    `first_name` = MD5(`first_name`),
    `last_name` = MD5(`last_name`),
    `remote_address` = '127.0.0.1'
;


# noinspection SqlWithoutWhere
UPDATE order_address SET
    `company` = MD5(`company`),
    `first_name` = MD5(`first_name`),
    `last_name` = MD5(`last_name`),
    `street` = MD5(`street`),
    `phone_number` = MD5(`phone_number`)
;

