<?php
/**
 * Copyright © 2019 Tomas Hubik <hubik.tomas@gmail.com>
 *
 * NOTICE OF LICENSE
 *
 * This file is part of QR Orders Manager PrestaShop module.
 *
 * QR Orders Manager PrestaShop module is free software: you can redistribute
 * it and/or modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation, either version 3 of the License,
 * or (at your option) any later version.
 *
 * QR Orders Manager PrestaShop module is distributed in the hope that it will
 * be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
 * Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * DISCLAIMER
 *
 * Do not edit or add to this file if you wish to upgrade this QR Orders Manager
 * module to newer versions in the future. If you wish to customize this module
 * for your needs please refer to http://www.prestashop.com for more information.
 *
 *  @author Tomas Hubik <hubik.tomas@gmail.com>
 *  @copyright  2019 Tomas Hubik
 *  @license    https://www.gnu.org/licenses/gpl-3.0.en.html  GNU General Public License (GPLv3)
 */

/**
 * Admin controller for orders search and management.
 */
class AdminQrOrdersManagerController extends ModuleAdminController
{
    public function __construct()
    {
        $this->bootstrap = true;
        $this->meta_title = $this->l('QR Orders Manager', 'qrordersmanager');

        parent::__construct();
    }
    
    /**
     * @see Controller::setMedia()
     */
    public function setMedia()
    {
        parent::setMedia();
        
        $this->addJquery();
        $this->addJS(_MODULE_DIR_ . $this->module->name . '/views/js/qrcamera.min.js');
        $this->addJS(_MODULE_DIR_ . $this->module->name . '/views/js/back.js');
        $this->addCSS(_MODULE_DIR_ . $this->module->name . '/views/css/back.css');
    }

    /**
     * @see AdminController::initContent()
     */
    public function initContent()
    {
        parent::initContent();

        $this->context->smarty->assign(array(
            'link' => Context::getContext()->link,
            'confirmation_required' => Configuration::get('QRORDERSMANAGER_CONFIRMATION')
        ));
        
        return $this->setTemplate('qrordersmanager.tpl');
    }
    
    /**
     * Handles ajax request for order data.
     */
    public function ajaxProcessGetOrder()
    {
        $orderReference = trim(Tools::getValue('orderReference'));
        $order = $this->getOrderByReference($orderReference);
        if (!$order || !Validate::isLoadedObject($order)) {
            $this->displayError($this->l('Order with specified order reference not found.', 'qrordersmanager'));
            exit;
        }
        $this->displayOrder($order);
    }
    
    /**
     * Changes order status to delivered.
     */
    public function ajaxProcessSetOrderDelivered()
    {
        // Find order
        $orderReference = trim(Tools::getValue('orderReference'));
        $order = $this->getOrderByReference($orderReference);
        if (!$order || !Validate::isLoadedObject($order)) {
            $this->displayError($this->l('Order with specified order reference not found.', 'qrordersmanager'));
            exit;
        }
        
        // Check if the order is not already in delivered status
        $orderState = new OrderState(Configuration::get('PS_OS_DELIVERED'));
        if (!Validate::isLoadedObject($orderState)) {
            $this->displayError($this->l('Unable to find delivered status ID.', 'qrordersmanager'), true);
        }
        $currentOrderState = $order->getCurrentOrderState();
        if ($currentOrderState->id == $orderState->id) {
            $this->displayError($this->l('The order has already been assigned this status.', 'qrordersmanager'));
        }
        
        // Create new OrderHistory
        $history = new OrderHistory();
        $history->id_order = $order->id;
        $history->id_employee = (int)$this->context->employee->id;

        $use_existings_payment = false;
        if (!$order->hasInvoice()) {
            $use_existings_payment = true;
        }
        $history->changeIdOrderState((int)$orderState->id, $order, $use_existings_payment);

        // Save all changes
        if ($history->addWithemail()) {
            // Synchronize quantities if needed
            if (Configuration::get('PS_ADVANCED_STOCK_MANAGEMENT')) {
                foreach ($order->getProducts() as $product) {
                    if (StockAvailable::dependsOnStock($product['product_id'])) {
                        StockAvailable::synchronize($product['product_id'], (int)$product['id_shop']);
                    }
                }
            }
        } else {
            $this->displayError($this->l('An error occurred while changing order status, or we were unable to send an email to the customer.', 'qrordersmanager'));
        }

        $this->displayOrder($order);
    }
    
    /**
     * Gets order from order reference
     *
     * $param string $orderReference Order reference
     *
     * @return Order object if found, false otherwise
     */
    protected function getOrderByReference($orderReference)
    {
        $orders = Order::getByReference($orderReference);
        if (!$orders || !$orders->count()) {
            return false;
        }
        if ($orders->count() != 1) {
            $this->displayError($this->l('More orders with specified reference found.', 'qrordersmanager'), true);
        }
        return $orders->getFirst();
    }
    
    /**
     * Displays order page for ajax return.
     *
     * $param Order $order Order object
     */
    protected function displayOrder($order)
    {
        if (!$order || !Validate::isLoadedObject($order)) {
            $this->displayError($this->l('Order object invalid.', 'qrordersmanager'), true);
        }
        
        // Check if the order is not already in delivered status
        $showDeliveredButton = true;
        $orderState = new OrderState(Configuration::get('PS_OS_DELIVERED'));
        if (!Validate::isLoadedObject($orderState)) {
            $this->displayError($this->l('Unable to find delivered status ID.', 'qrordersmanager'));
            $showDeliveredButton = false;
        } else {
            $currentOrderState = $order->getCurrentOrderState();
            if ($currentOrderState->id == $orderState->id) {
                $showDeliveredButton = false;
            }
        }
        
        // Load order history
        $history = $order->getHistory($this->context->language->id);
        foreach ($history as &$order_state) {
            $order_state['text-color'] = Tools::getBrightness($order_state['color']) < 128 ? 'white' : 'black';
        }
        
        // Load customer
        $customer = new Customer($order->id_customer);
        
        // Load messages
        $messages = Message::getMessagesByOrderId($order->id, true);
        
        // Load currency
        $currency = new Currency($order->id_currency);
        
        // Load and process products
        $products = $order->getProducts();
        foreach ($products as &$product) {
            if ($product['image'] != null) {
                $name = 'product_mini_'.(int)$product['product_id'].(isset($product['product_attribute_id']) ? '_'.(int)$product['product_attribute_id'] : '').'.jpg';
                // generate image cache, only for back office
                $product['image_tag'] = ImageManager::thumbnail(_PS_IMG_DIR_.'p/'.$product['image']->getExistingImgPath().'.jpg', $name, 45, 'jpg');
                if (file_exists(_PS_TMP_IMG_DIR_.$name)) {
                    $product['image_size'] = getimagesize(_PS_TMP_IMG_DIR_.$name);
                } else {
                    $product['image_size'] = false;
                }
            }
        }
        ksort($products);
        // products current stock (from stock_available)
        foreach ($products as &$product) {
            // Get total customized quantity for current product
            $customized_product_quantity = 0;

            if (is_array($product['customizedDatas'])) {
                foreach ($product['customizedDatas'] as $customizationPerAddress) {
                    foreach ($customizationPerAddress as $customization) {
                        $customized_product_quantity += (int)$customization['quantity'];
                    }
                }
            }
            $product['customized_product_quantity'] = $customized_product_quantity;
            $product['current_stock'] = StockAvailable::getQuantityAvailableByProduct($product['product_id'], $product['product_attribute_id'], $product['id_shop']);
            $resume = OrderSlip::getProductSlipResume($product['id_order_detail']);
            $product['quantity_refundable'] = $product['product_quantity'] - $resume['product_quantity'];
            $product['amount_refundable'] = $product['total_price_tax_excl'] - $resume['amount_tax_excl'];
            $product['amount_refundable_tax_incl'] = $product['total_price_tax_incl'] - $resume['amount_tax_incl'];
            $product['amount_refund'] = Tools::displayPrice($resume['amount_tax_incl'], $currency);
            $product['refund_history'] = OrderSlip::getProductSlipDetail($product['id_order_detail']);
            $product['return_history'] = OrderReturn::getProductReturnDetail($product['id_order_detail']);
        }
        
        // Load discounts
        $discounts = $order->getCartRules();
        
        $templateVars = array(
            'order' => $order,
            'history' => $history,
            'customer' => $customer,
            'messages' => $messages,
            'products' => $products,
            'currency' => $currency,
            'discounts' => $discounts,
            'showDeliveredButton' => $showDeliveredButton,
            'link' => Context::getContext()->link
        );
        
        $template = $this->createTemplate('order.tpl');
        $template->assign($templateVars);
        $this->displaySmartyContent($template);
    }
    
    /**
     * Displays error notification for ajax return.
     *
     * $param string $message Error message
     * @param bool $fatal Halts the whole execution if true
     */
    protected function displayError($message, $fatal = false)
    {
        $template = $this->createTemplate('error.tpl');
        if ($fatal) {
            $message = $this->l('FATAL ERROR', 'qrordersmanager') . ': '. $message;
        }
        $template->assign(array(
            'message' => $message
        ));
        $this->displaySmartyContent($template);
        if ($fatal) {
            die;
        }
    }
    
    /**
     * Displays raw smarty content without header, footer, etc.
     *
     * @param array|string $content Template file(s) to be rendered.
     */
    protected function displaySmartyContent($template)
    {
        $this->content_only = true;
        $this->smartyOutputContent($template);
        $this->content_only = false;
    }
}
