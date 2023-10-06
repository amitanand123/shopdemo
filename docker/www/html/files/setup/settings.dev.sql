--
-- FIRST --> Do not add your SQL-Statements before this
-- Set all Sales-Channels in Maintenance-Mode
--
UPDATE `sales_channel` SET `maintenance` = 1;


--
-- Set Host
--
UPDATE `sales_channel_domain` SET `url` = 'http://dev.m-medientechnik.de/' WHERE `id` = 0xcdcfbb5ea2dd4891ae7a782c678c9aaa;
UPDATE `sales_channel_domain` SET `url` = 'https://dev.m-medientechnik.de/' WHERE `id` = 0x47c8d1b3ba684d6ba847ab87d90ca3df;



--
-- Set Mail-Configuration to MailTrap
--
#DELETE FROM system_config WHERE configuration_key LIKE 'core.mailerSettings%';
UPDATE system_config SET configuration_value = '{"_value":"smtp"}'                      WHERE configuration_key = 'core.mailerSettings.emailAgent';
UPDATE system_config SET configuration_value = '{"_value":"tls"}'                       WHERE configuration_key = 'core.mailerSettings.encryption';
UPDATE system_config SET configuration_value = '{"_value":"smtp.mailtrap.io"}'          WHERE configuration_key = 'core.mailerSettings.host';
UPDATE system_config SET configuration_value = '{"_value":"98d8b61ae5ecd7"}'            WHERE configuration_key = 'core.mailerSettings.password';
UPDATE system_config SET configuration_value = '{"_value":2525}'                        WHERE configuration_key = 'core.mailerSettings.port';
UPDATE system_config SET configuration_value = '{"_value":"shop@m-medientechnik.de"}'   WHERE configuration_key = 'core.mailerSettings.senderAddress';
UPDATE system_config SET configuration_value = '{"_value":"-t"}'                        WHERE configuration_key = 'core.mailerSettings.sendMailOptions';
UPDATE system_config SET configuration_value = '{"_value":"15eac83843f1f8"}'            WHERE configuration_key = 'core.mailerSettings.username';


--
-- Set "Stripe Payment" to Sandbox-Mode
--
UPDATE system_config SET configuration_value = '{"_value":"DE"}' WHERE configuration_key = 'StripeShopwarePayment.config.stripeAccountCountryIso';
UPDATE system_config SET configuration_value = '{"_value":"we_1LVWH2FAFYhx35QlWlqV0c2T"}' WHERE configuration_key = 'StripeShopwarePayment.config.stripeWebhookId';
UPDATE system_config SET configuration_value = '{"_value":true}' WHERE configuration_key = 'StripeShopwarePayment.config.isSavingCreditCardsAllowed';
UPDATE system_config SET configuration_value = '{"_value":"pk_test_51LVVwXFAFYhx35Qlz1ITcTRErJOeZcoDpSnUEbaNzEp1dPlIR7WXqk8oYsmECX8vp58INP0fRwxjT51egHLa2JiR00fVQzKdXp"}' WHERE configuration_key = 'StripeShopwarePayment.config.stripePublicKey';
UPDATE system_config SET configuration_value = '{"_value":"whsec_lXEogIfiUCx6OU4vTuzB9iVlY5T7cbZu"}' WHERE configuration_key = 'StripeShopwarePayment.config.stripeWebhookSecret';
UPDATE system_config SET configuration_value = '{"_value":true}' WHERE configuration_key = 'StripeShopwarePayment.config.shouldShowPaymentProviderLogos';
UPDATE system_config SET configuration_value = '{"_value":"sk_test_51LVVwXFAFYhx35QlCXkpycMwdqE1p9EWnWHNVWgHfSxdW3FcU5Jz5LYHtPX67mP9jo6Vh3oMlBCJMDlGBwGGa1rd00j6LApmDn"}' WHERE configuration_key = 'StripeShopwarePayment.config.stripeSecretKey';
UPDATE system_config SET configuration_value = '{"_value":true}' WHERE configuration_key = 'StripeShopwarePayment.config.isSavingSepaBankAccountsAllowed';






--
-- LAST --> Do not add your SQL-Statements after this
-- Remove Maintenance-Mode from all Sales-Channels
--
UPDATE `sales_channel` SET `maintenance` = 0;
