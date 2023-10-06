<?php declare(strict_types=1);

namespace TkDemoPlugin\Migration;

use Doctrine\DBAL\Connection;
use Doctrine\DBAL\Exception;
use Shopware\Core\Framework\Migration\MigrationStep;
use Shopware\Core\Framework\Uuid\Uuid;


class Migration1686388701DemoDataTable extends MigrationStep
{
    public final function getCreationTimestamp(): int
    {
        return 1686388701;
    }

    /**
     * @throws Exception
     */
    public final function update(Connection $connection): void
    {
        $someUUID = Uuid::randomHex();

        $connection->executeStatement(
            <<<SQL
            CREATE TABLE IF NOT EXISTS `tk_demo_data` (
                            `id` binary(16) NOT NULL,
                            `first_name` varchar(100) NOT NULL,
                            `last_name` varchar(100) NOT NULL,
                            `created_at` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
                            `updated_at` datetime(3) DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP(3),
                            PRIMARY KEY (`id`)
                            );

         --    INSERT INTO `tk_demo_data` (id, first_name, last_name)
         --       VALUES (0x{$someUUID}, 'Nirav','Banushali');   
         
         INSERT INTO `tk_demo_data` (id, first_name, last_name)
                VALUES (0xd8fa33401da9428eacaf1513feaa93e1, 'Nirav','Banushali');
SQL
        );
    }

    public final function updateDestructive(Connection $connection): void
    {
        // implement update destructive
    }
}
