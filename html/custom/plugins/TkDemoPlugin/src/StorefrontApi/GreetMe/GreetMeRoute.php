<?php declare(strict_types=1);

namespace TkDemoPlugin\StorefrontApi\GreetMe;


use Shopware\Core\Framework\DataAbstractionLayer\EntityRepository;
use Shopware\Core\Framework\DataAbstractionLayer\Search\Criteria;
use Shopware\Core\Framework\Routing\Annotation\Since;
use Shopware\Core\System\SalesChannel\SalesChannelContext;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;
use TkDemoPlugin\Entity\DemoData\DemoDataEntity;

/**
 * @Route(defaults={"_routeScope"={"store-api"}})
 */
class GreetMeRoute
{
    public function __construct(
        private readonly EntityRepository $demoDataRepository
    ) {

    }

    /**
     * @Since("6.3.0.0")
     * @Route("/store-api/tkDemoPlugin/greetMe", name="store-api.tkdemoplugin.greetme", methods={"GET", "POST"})
     */
    public final function greetMe(Request $request, SalesChannelContext $context): Response
    {
        $criteria = new Criteria(["d8fa33401da9428eacaf1513feaa93e1"]);
        /** @var DemoDataEntity $latestDemoData */
        $latestDemoData = $this->demoDataRepository->search($criteria, $context->getContext())->first();

        return new Response("Hello dear " . $latestDemoData->getFirstName() . "!");
    }

}