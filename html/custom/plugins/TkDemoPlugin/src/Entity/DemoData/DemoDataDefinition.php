<?php

namespace TkDemoPlugin\Entity\DemoData;

use Shopware\Core\Framework\DataAbstractionLayer\EntityDefinition;
use Shopware\Core\Framework\DataAbstractionLayer\Field\Flag\ApiAware;
use Shopware\Core\Framework\DataAbstractionLayer\Field\Flag\PrimaryKey;
use Shopware\Core\Framework\DataAbstractionLayer\Field\Flag\Required;
use Shopware\Core\Framework\DataAbstractionLayer\Field\IdField;
use Shopware\Core\Framework\DataAbstractionLayer\Field\StringField;
use Shopware\Core\Framework\DataAbstractionLayer\FieldCollection;

class DemoDataDefinition extends EntityDefinition
{

    public const ENTITY_NAME = 'tk_demo_data';

    public final function getEntityName(): string
    {
        return self::ENTITY_NAME;
    }

    public final function getEntityClass(): string
    {
        return DemoDataEntity::class;
    }

    protected function defineFields(): FieldCollection
    {
        /**
         *  See: https://developer.shopware.com/docs/guides/plugins/plugins/framework/data-handling/add-custom-complex-data
         *  for a reference of flags see: https://developer.shopware.com/docs/resources/references/core-reference/dal-reference/flags-reference
         *  for a reference of fields see: https://developer.shopware.com/docs/resources/references/core-reference/dal-reference/fields-reference
         */
        return new FieldCollection([
            (new IdField('id', 'id'))->addFlags(new ApiAware(), new PrimaryKey(), new Required()),
            (new StringField('first_name', 'firstName'))->addFlags(new ApiAware(), new Required()),
            (new StringField('last_name', 'lastName'))->addFlags(new ApiAware(), new Required()),
        ]);
    }
}