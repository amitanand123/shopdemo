--
-- order
--
ALTER TABLE `order`
    DROP COLUMN `order_date`,
    ADD `order_date`     date GENERATED ALWAYS AS (cast(`order_date_time` as date)) STORED AFTER `order_date_time`,
    DROP COLUMN `amount_total`,
    ADD `amount_total`   double GENERATED ALWAYS AS (json_unquote(json_extract(`price`, '$.totalPrice'))) VIRTUAL AFTER `order_date`,
    DROP COLUMN `amount_net`,
    ADD `amount_net`     double GENERATED ALWAYS AS (json_unquote(json_extract(`price`, '$.netPrice'))) VIRTUAL AFTER `amount_total`,
    DROP COLUMN `position_price`,
    ADD `position_price` double GENERATED ALWAYS AS (json_unquote(json_extract(`price`, '$.positionPrice'))) VIRTUAL AFTER `amount_net`,
    DROP COLUMN `tax_status`,
    ADD `tax_status`     varchar(255) COLLATE utf8mb4_unicode_ci GENERATED ALWAYS AS (json_unquote(json_extract(`price`, '$.taxStatus'))) VIRTUAL AFTER `position_price`,
    DROP COLUMN `shipping_total`,
    ADD `shipping_total` double GENERATED ALWAYS AS (json_unquote(json_extract(`shipping_costs`, '$.totalPrice'))) VIRTUAL AFTER `shipping_costs`
;


--
-- order_delivery_position
--
ALTER TABLE `order_delivery_position`
    DROP COLUMN `total_price`,
    ADD `total_price` int(11) GENERATED ALWAYS AS (json_unquote(json_extract(`price`, '$.totalPrice'))) VIRTUAL AFTER `price`,
    DROP COLUMN `unit_price`,
    ADD `unit_price`  int(11) GENERATED ALWAYS AS (json_unquote(json_extract(`price`, '$.unitPrice'))) VIRTUAL AFTER `total_price`,
    DROP COLUMN `quantity`,
    ADD `quantity`    int(11) GENERATED ALWAYS AS (json_unquote(json_extract(`price`, '$.quantity'))) VIRTUAL AFTER `unit_price`
;


--
-- order_line_item
--
ALTER TABLE `order_line_item`
    DROP COLUMN `unit_price`,
    ADD `unit_price`  double GENERATED ALWAYS AS (json_unquote(json_extract(`price`, '$.unitPrice'))) VIRTUAL after `quantity`,
    DROP COLUMN `total_price`,
    ADD `total_price` double GENERATED ALWAYS AS (json_unquote(json_extract(`price`, '$.totalPrice'))) VIRTUAL after `unit_price`
;


--
-- product
--
ALTER TABLE `product`
    DROP COLUMN `variant_listing_config`,
    ADD `variant_listing_config` json GENERATED ALWAYS AS (
        (case
             when ((`display_parent` is not null) or (`main_variant_id` is not null) or (`configurator_group_config` is not null))
                 then json_object('displayParent', `display_parent`, 'mainVariantId', lower(hex(`main_variant_id`)),
                                  'configuratorGroupConfig', json_extract(`configurator_group_config`, '$')) end)) VIRTUAL AFTER `display_parent`
;


--
-- product_keyword_dictionary
--
ALTER TABLE `product_keyword_dictionary`
    DROP COLUMN `reversed`,
    ADD `reversed` varchar(500) COLLATE utf8mb4_unicode_ci GENERATED ALWAYS AS (reverse(`keyword`)) STORED AFTER `keyword`
;
