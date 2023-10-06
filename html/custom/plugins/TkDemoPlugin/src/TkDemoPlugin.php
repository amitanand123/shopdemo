<?php declare(strict_types=1);

namespace TkDemoPlugin;

use Doctrine\DBAL\Connection;
use Doctrine\DBAL\Exception;
use Shopware\Core\Framework\Plugin;
use Shopware\Core\Framework\Plugin\Context\UninstallContext;

class TkDemoPlugin extends Plugin
{
    /**
     * @throws Exception
     */
    public final function uninstall(UninstallContext $uninstallContext): void
    {
        parent::uninstall($uninstallContext);

        if ($uninstallContext->keepUserData()) {
            return;
        }

        /** @var  Connection $connection */
        $connection = $this->container->get(Connection::class);

        $connection->executeStatement(
            <<<SQL
        DROP TABLE IF EXISTS tk_demo_data;
SQL
        );
    }
}