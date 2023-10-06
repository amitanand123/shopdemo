<?php declare(strict_types=1);

namespace TkDemoPlugin\Entity\DemoData;

use Shopware\Core\Framework\DataAbstractionLayer\Entity;
use Shopware\Core\Framework\DataAbstractionLayer\EntityIdTrait;

class DemoDataEntity extends Entity
{
    use EntityIdTrait;

    protected string $firstName;
    protected string $lastname;

    /**
     * @return string
     */
    public function getFirstName(): string
    {
        return $this->firstName;
    }

    /**
     * @param string $firstName
     * @return DemoDataEntity
     */
    public function setFirstName(string $firstName): DemoDataEntity
    {
        $this->firstName = $firstName;
        return $this;
    }

    /**
     * @return string
     */
    public function getLastname(): string
    {
        return $this->lastname;
    }

    /**
     * @param string $lastname
     * @return DemoDataEntity
     */
    public function setLastname(string $lastname): DemoDataEntity
    {
        $this->lastname = $lastname;
        return $this;
    }
}