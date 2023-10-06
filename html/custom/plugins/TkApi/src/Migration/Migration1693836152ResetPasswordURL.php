<?php

declare(strict_types=1);

namespace TkApi\Migration;

use Doctrine\DBAL\Connection;
use Doctrine\DBAL\Exception;
use Shopware\Core\Framework\Migration\MigrationStep;

/**
 * This Migration makes sure that we can execute the Password-Reset Workflow triggered from the UCP side.
 * Needed to enable: https://tk-bamx.atlassian.net/browse/MESS-64
 */
class Migration1693836152ResetPasswordURL extends MigrationStep
{
    public function getCreationTimestamp(): int
    {
        return 1693836152;
    }

    /**
     * @throws Exception
     */
    public function update(Connection $connection): void
    {
        /** We need a static UUID here, because we do not want to insert multiple entries,
         * when activating/deactivating the plugin
         */
        $someUUID = "0xdba731ba4b2d11eebe560242ac120002";

        /** We are using REPLACE instead of insert, otherwise we will get a unique key constraint violation,
         * when installing the plugin a second time. First-time REPLACE will do an insert.
         * Second-Time REPLACE will delete the entry and re-create it.
         *
         * sales_channel_id = id of headless sales-channel
         */
        $connection->executeStatement(
            <<<SQL
        REPLACE INTO system_config (id,
                                   configuration_key,
                                   configuration_value,
                                   sales_channel_id,
                                   created_at)
        VALUES ($someUUID,
                'core.loginRegistration.pwdRecoverUrl',
                '{"_value": "/registration/password-confirm-workflow?hash=%%RECOVERHASH%%"}',
                0x98432def39fc4624b33213a56b8c944d,
                CURRENT_TIMESTAMP);
SQL
        );

    }

    public function updateDestructive(Connection $connection): void
    {
    }
}