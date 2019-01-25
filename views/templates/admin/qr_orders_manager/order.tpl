{*
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
 *}

<div class="row">
    <div class="col-lg-12">
        <span class="badge big-badge margin-bottom-10">
            <a href="{$link->getAdminLink('AdminOrders')|escape:'html':'UTF-8'}&amp;vieworder&amp;id_order={$order->id|intval}">
                <i class="icon-credit-card"></i> Order {l s='#' mod='qrordersmanager'}{$order->id|escape:'html':'UTF-8'}<br>{$order->reference|escape:'html':'UTF-8'}
            </a>
        </span>
        {if $customer->id}
            <span class="badge big-badge margin-bottom-10">
                <a href="{$link->getAdminLink('AdminCustomers')|escape:'html':'UTF-8'}&amp;viewcustomer&amp;id_customer={$customer->id|intval}">
                    <i class="icon-user"></i> Customer {l s='#' mod='qrordersmanager'}{$customer->id|escape:'html':'UTF-8'}<br>{$customer->firstname|escape:'html':'UTF-8'} {$customer->lastname|escape:'html':'UTF-8'} ({$customer->email|escape:'html':'UTF-8'})
                </a>
            </span>
        {else}
            <span class="badge big-badge margin-bottom-10">
                <i class="icon-user"></i> Customer<br>{l s='Customer not found' mod='qrordersmanager'}
            </span>

        {/if}
    </div>
</div>

<div class="row">
    <div class="col-lg-4">
        <div class="panel">
            <h3><i class="icon-time"></i> {l s='Status' mod='qrordersmanager'}</h3>
            <div class="table-responsive">
                <table class="table history-status row-margin-bottom">
                    <tbody>
                        {foreach from=$history item=row key=key}
                            {if ($key == 0)}
                                <tr>
                                    <td style="background-color:{$row['color']|escape:'html':'UTF-8'}"><img src="../img/os/{$row['id_order_state']|intval}.gif" width="16" height="16" alt="{$row['ostate_name']|escape:'html':'UTF-8'}" /></td>
                                    <td style="background-color:{$row['color']|escape:'html':'UTF-8'};color:{$row['text-color']|escape:'html':'UTF-8'}">{$row['ostate_name']|escape:'html':'UTF-8'}</td>
                                    <td style="background-color:{$row['color']|escape:'html':'UTF-8'};color:{$row['text-color']|escape:'html':'UTF-8'}">{dateFormat date=$row['date_add'] full=true}</td>
                                </tr>
                            {else}
                                <tr>
                                    <td><img src="../img/os/{$row['id_order_state']|intval}.gif" width="16" height="16" /></td>
                                    <td>{$row['ostate_name']|escape:'html':'UTF-8'}</td>
                                    <td>{dateFormat date=$row['date_add'] full=true}</td>
                                </tr>
                            {/if}
                        {/foreach}
                    </tbody>
                </table>
            </div>
            {if $showDeliveredButton}
                <button type="submit" id="markAsDeliveredButton" name="markAsDelivered" class="btn btn-primary margin-top-20">
                    {l s='Mark as delivered' mod='qrordersmanager'}
                </button>
                <script>
                    $(document).ready(function() {
                        $("#markAsDeliveredButton").click(function() {
                            if (!confirmationRequired || confirm("{l s='Really mark order %s as delivered?' sprintf=[$order->reference|escape:'javascript'] mod='qrordersmanager'}")) {
                                markOrderAsDelivered('{$order->reference|escape:'javascript'}', ajaxUrl, $("#resultPanel"));
                            }
                        });
                    });
                </script>
            {/if}
        </div>
    </div>

    <div class="col-lg-8">
        <div class="panel">
            <h3><i class="icon-shopping-cart"></i> {l s='Products' mod='qrordersmanager'}</h3>
            {capture "TaxMethod"}
                {if ($order->getTaxCalculationMethod() == $smarty.const.PS_TAX_EXC)}
                    {l s='tax excluded' mod='qrordersmanager'}
                {else}
                    {l s='tax included' mod='qrordersmanager'}
                {/if}
            {/capture}
            <div class="table-responsive">
                <table class="table" id="orderProducts">
                    <thead>
                        <tr>
                            <th></th>
                            <th>
                                <span class="title_box ">{l s='Product' mod='qrordersmanager'}</span>
                            </th>
                            <th>
                                <span class="title_box ">{l s='Unit Price' mod='qrordersmanager'}</span>
                                <small class="text-muted">{$smarty.capture.TaxMethod|escape:'html':'UTF-8'}</small>
                            </th>
                            <th class="text-center">
                                <span class="title_box ">{l s='Qty' mod='qrordersmanager'}</span>
                            </th>
                            {if ($order->hasBeenPaid())}
                                <th class="text-center">
                                    <span class="title_box ">{l s='Refunded' mod='qrordersmanager'}</span>
                                </th>
                            {/if}
                            {if ($order->hasBeenDelivered() || $order->hasProductReturned())}
                                <th class="text-center">
                                    <span class="title_box ">{l s='Returned' mod='qrordersmanager'}</span>
                                </th>
                            {/if}
                            <th>
                                <span class="title_box ">{l s='Total' mod='qrordersmanager'}</span>
                                <small class="text-muted">{$smarty.capture.TaxMethod|escape:'html':'UTF-8'}</small>
                            </th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach from=$products item=product key=k}
                            {if ($order->getTaxCalculationMethod() == $smarty.const.PS_TAX_EXC)}
                                {assign var=product_price value=($product['unit_price_tax_excl'] + $product['ecotax'])}
                            {else}
                                {assign var=product_price value=$product['unit_price_tax_incl']}
                            {/if}
                            {if $product['customizedDatas']}
                                <tr class="customized customized-{$product['id_order_detail']|intval} product-line-row">
                                    <td>
                                        {if isset($product['image']) && $product['image']->id|intval}{$product['image_tag']}{else}--{/if}
                                    </td>
                                    <td>
                                        <a href="{$link->getAdminLink('AdminProducts')|escape:'html':'UTF-8'}&amp;id_product={$product['product_id']|intval}&amp;updateproduct">
                                            <span class="productName">{$product['product_name']|escape:'html':'UTF-8'} - {l s='Customized' mod='qrordersmanager'}</span><br />
                                            {if ($product['product_reference'])}{l s='Reference:' mod='qrordersmanager'} {$product['product_reference']|escape:'html':'UTF-8'}<br />{/if}
                                            {if ($product['product_supplier_reference'])}{l s='Supplier reference:' mod='qrordersmanager'} {$product['product_supplier_reference']|escape:'html':'UTF-8'}{/if}
                                        </a>
                                    </td>
                                    <td>
                                        <span class="product_price_show">{displayPrice price=$product_price currency=$currency->id|intval}</span>
                                    </td>
                                    <td class="productQuantity text-center">
                                        {$product['customizationQuantityTotal']|escape:'html':'UTF-8'}
                                    </td>
                                    {if ($order->hasBeenPaid())}
                                        <td class="productQuantity text-center">
                                            {$product['customizationQuantityRefunded']|escape:'html':'UTF-8'}
                                        </td>
                                    {/if}
                                    {if ($order->hasBeenDelivered() || $order->hasProductReturned())}
                                        <td class="productQuantity text-center">
                                            {$product['customizationQuantityReturned']|escape:'html':'UTF-8'}
                                        </td>
                                    {/if}
                                    <td class="total_product">
                                        {if ($order->getTaxCalculationMethod() == $smarty.const.PS_TAX_EXC)}
                                            {displayPrice price=($product['unit_price_tax_excl'] * $product['customizationQuantityTotal']) currency=$currency->id|intval}
                                        {else}
                                            {displayPrice price=($product['unit_price_tax_incl'] * $product['customizationQuantityTotal']) currency=$currency->id|intval}
                                        {/if}
                                    </td>
                                </tr>
                                {foreach $product['customizedDatas'] as $customizationPerAddress}
                                    {foreach $customizationPerAddress as $customizationId => $customization}
                                        <tr class="customized customized-{$product['id_order_detail']|intval}">
                                            <td colspan="2">
                                                <div class="form-horizontal">
                                                    {foreach $customization.datas as $type => $datas}
                                                        {if ($type == Product::CUSTOMIZE_FILE)}
                                                            {foreach from=$datas item=data}
                                                                <div class="form-group">
                                                                    <span class="col-lg-4 control-label"><strong>{if $data['name']}{$data['name']|escape:'html':'UTF-8'}{else}{l s='Picture #' mod='qrordersmanager'}{$data@iteration|intval}{/if}</strong></span>
                                                                    <div class="col-lg-8">
                                                                        <a href="displayImage.php?img={$data['value']|escape:'url'}&amp;name={$order->id|intval}-file{$data@iteration|intval}" class="_blank">
                                                                            <img class="img-thumbnail" src="{$smarty.const._THEME_PROD_PIC_DIR_|escape:'html':'UTF-8'}{$data['value']|escape:'html':'UTF-8'}_small" alt=""/>
                                                                        </a>
                                                                    </div>
                                                                </div>
                                                            {/foreach}
                                                        {elseif ($type == Product::CUSTOMIZE_TEXTFIELD)}
                                                            {foreach from=$datas item=data}
                                                                <div class="form-group">
                                                                    <span class="col-lg-4 control-label"><strong>{if $data['name']}{l s='%s' sprintf=[$data['name']|escape:'html':'UTF-8'] mod='qrordersmanager'}{else}{l s='Text #%s' sprintf=[$data@iteration|intval] mod='qrordersmanager'}{/if}</strong></span>
                                                                    <div class="col-lg-8">
                                                                        <p class="form-control-static">{$data['value']|escape:'html':'UTF-8'}</p>
                                                                    </div>
                                                                </div>
                                                            {/foreach}
                                                        {/if}
                                                    {/foreach}
                                                </div>
                                            </td>
                                            <td>-</td>
                                            <td class="productQuantity text-center">
                                                <span class="product_quantity_show{if (int)$customization['quantity'] > 1} red bold{/if}">{$customization['quantity']|escape:'html':'UTF-8'}</span>
                                            </td>
                                            {if ($order->hasBeenPaid())}
                                                <td class="text-center">
                                                    {if !empty($product['amount_refund'])}
                                                        {l s='%s (%s refund)' sprintf=[$customization['quantity_refunded']|escape:'html':'UTF-8', $product['amount_refund']|escape:'html':'UTF-8'] mod='qrordersmanager'}
                                                    {/if}
                                                </td>
                                            {/if}
                                            {if ($order->hasBeenDelivered())}
                                                <td class="text-center">{$customization['quantity_returned']|escape:'html':'UTF-8'}</td>
                                            {/if}
                                            <td class="total_product">
                                                {if ($order->getTaxCalculationMethod() == $smarty.const.PS_TAX_EXC)}
                                                    {displayPrice price=($product['unit_price_tax_excl'] * $customization['quantity']) currency=$currency->id|intval}
                                                {else}
                                                    {displayPrice price=($product['unit_price_tax_incl'] * $customization['quantity']) currency=$currency->id|intval}
                                                {/if}
                                            </td>
                                        </tr>
                                    {/foreach}
                                {/foreach}
                            {/if}
                            {if ($product['product_quantity'] > $product['customized_product_quantity'])}
                                <tr class="product-line-row">
                                    <td>{if isset($product.image) && $product.image->id}{$product.image_tag}{/if}</td>
                                    <td>
                                        <a href="{$link->getAdminLink('AdminProducts')|escape:'html':'UTF-8'}&amp;id_product={$product['product_id']|intval}&amp;updateproduct">
                                            <span class="productName">{$product['product_name']|escape:'html':'UTF-8'}</span><br />
                                            {if $product.product_reference}{l s='Reference:' mod='qrordersmanager'} {$product.product_reference|escape:'html':'UTF-8'}<br />{/if}
                                            {if $product.product_supplier_reference}{l s='Supplier reference:' mod='qrordersmanager'} {$product.product_supplier_reference|escape:'html':'UTF-8'}{/if}
                                        </a>
                                    </td>
                                    <td>
                                        <span class="product_price_show">{displayPrice price=$product_price currency=$currency->id}</span>
                                    </td>
                                    <td class="productQuantity text-center">
                                        <span class="product_quantity_show{if (int)$product['product_quantity'] - (int)$product['customized_product_quantity'] > 1} badge{/if}">{((int)$product['product_quantity'] - (int)$product['customized_product_quantity'])|intval}</span>
                                    </td>
                                    {if ($order->hasBeenPaid())}
                                        <td class="productQuantity text-center">
                                            {if !empty($product['amount_refund'])}
                                                {l s='%s (%s refund)' sprintf=[$product['product_quantity_refunded']|escape:'html':'UTF-8', $product['amount_refund']|escape:'html':'UTF-8'] mod='qrordersmanager'}
                                            {/if}
                                            {if count($product['refund_history'])}
                                                <span class="tooltip">
                                                    <span class="tooltip_label tooltip_button">+</span>
                                                    <span class="tooltip_content">
                                                    <span class="title">{l s='Refund history' mod='qrordersmanager'}</span>
                                                    {foreach $product['refund_history'] as $refund}
                                                        {l s='%1s - %2s' sprintf=[{dateFormat date=$refund.date_add}, {displayPrice price=$refund.amount_tax_incl}] mod='qrordersmanager'}<br />
                                                    {/foreach}
                                                    </span>
                                                </span>
                                            {/if}
                                        </td>
                                    {/if}
                                    {if $order->hasBeenDelivered() || $order->hasProductReturned()}
                                        <td class="productQuantity text-center">
                                            {$product['product_quantity_return']|escape:'html':'UTF-8'}
                                            {if count($product['return_history'])}
                                                <span class="tooltip">
                                                    <span class="tooltip_label tooltip_button">+</span>
                                                    <span class="tooltip_content">
                                                    <span class="title">{l s='Return history' mod='qrordersmanager'}</span>
                                                    {foreach $product['return_history'] as $return}
                                                        {l s='%1s - %2s - %3s' sprintf=[{dateFormat date=$return.date_add}, $return.product_quantity|escape:'html':'UTF-8', $return.state|escape:'html':'UTF-8'] mod='qrordersmanager'}<br />
                                                    {/foreach}
                                                    </span>
                                                </span>
                                            {/if}
                                        </td>
                                    {/if}
                                    <td class="total_product">
                                        {displayPrice price=($product_price * ($product['product_quantity'] - $product['customizationQuantityTotal'])) currency=$currency->id}
                                    </td>
                                </tr>
                            {/if}
                        {/foreach}
                    </tbody>
                </table>
            </div>
            <div class="row margin-top-20">
                <div class="col-md-6">
                    <div class="alert alert-warning">
                        {l s='For this customer group, prices are displayed as: [1]%s[/1]' sprintf=[$smarty.capture.TaxMethod|escape:'html':'UTF-8'] tags=['<strong>'] mod='qrordersmanager'}
                        {if !Configuration::get('PS_ORDER_RETURN')}
                            <br/><strong>{l s='Merchandise returns are disabled' mod='qrordersmanager'}</strong>
                        {/if}
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="panel panel-vouchers" style="{if !sizeof($discounts)}display:none;{/if}">
                        {if sizeof($discounts)}
                            <div class="table-responsive">
                                <table class="table">
                                    <thead>
                                        <tr>
                                            <th>
                                                <span class="title_box ">
                                                    {l s='Discount name' mod='qrordersmanager'}
                                                </span>
                                            </th>
                                            <th>
                                                <span class="title_box ">
                                                    {l s='Value' mod='qrordersmanager'}
                                                </span>
                                            </th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {foreach from=$discounts item=discount}
                                            <tr>
                                                <td>{$discount['name']|escape:'html':'UTF-8'}</td>
                                                <td>
                                                    {if $discount['value'] != 0.00}
                                                        -
                                                    {/if}
                                                    {displayPrice price=$discount['value'] currency=$currency->id}
                                                </td>
                                            </tr>
                                        {/foreach}
                                    </tbody>
                                </table>
                            </div>
                        {/if}
                    </div>
                    <div class="panel panel-total">
                        <div class="table-responsive">
                            <table class="table">
                                {if ($order->getTaxCalculationMethod() == $smarty.const.PS_TAX_EXC)}
                                    {assign var=order_product_price value=($order->total_products)}
                                    {assign var=order_discount_price value=$order->total_discounts_tax_excl}
                                    {assign var=order_wrapping_price value=$order->total_wrapping_tax_excl}
                                    {assign var=order_shipping_price value=$order->total_shipping_tax_excl}
                                {else}
                                    {assign var=order_product_price value=$order->total_products_wt}
                                    {assign var=order_discount_price value=$order->total_discounts_tax_incl}
                                    {assign var=order_wrapping_price value=$order->total_wrapping_tax_incl}
                                    {assign var=order_shipping_price value=$order->total_shipping_tax_incl}
                                {/if}
                                <tr id="total_products">
                                    <td class="text-right">{l s='Products' mod='qrordersmanager'}</td>
                                    <td class="amount text-right nowrap">
                                        {displayPrice price=$order_product_price currency=$currency->id}
                                    </td>
                                </tr>
                                <tr id="total_discounts" {if $order->total_discounts_tax_incl == 0}style="display: none;"{/if}>
                                    <td class="text-right">{l s='Discounts' mod='qrordersmanager'}</td>
                                    <td class="amount text-right nowrap">
                                        -{displayPrice price=$order_discount_price currency=$currency->id}
                                    </td>
                                </tr>
                                <tr id="total_wrapping" {if $order->total_wrapping_tax_incl == 0}style="display: none;"{/if}>
                                    <td class="text-right">{l s='Wrapping' mod='qrordersmanager'}</td>
                                    <td class="amount text-right nowrap">
                                        {displayPrice price=$order_wrapping_price currency=$currency->id}
                                    </td>
                                </tr>
                                <tr id="total_shipping">
                                    <td class="text-right">{l s='Shipping' mod='qrordersmanager'}</td>
                                    <td class="amount text-right nowrap" >
                                        {displayPrice price=$order_shipping_price currency=$currency->id}
                                    </td>
                                </tr>
                                {if ($order->getTaxCalculationMethod() == $smarty.const.PS_TAX_EXC)}
                                    <tr id="total_taxes">
                                        <td class="text-right">{l s='Taxes' mod='qrordersmanager'}</td>
                                        <td class="amount text-right nowrap" >{displayPrice price=($order->total_paid_tax_incl-$order->total_paid_tax_excl) currency=$currency->id}</td>
                                    </tr>
                                {/if}
                                {assign var=order_total_price value=$order->total_paid_tax_incl}
                                <tr id="total_order">
                                    <td class="text-right"><strong>{l s='Total' mod='qrordersmanager'}</strong></td>
                                    <td class="amount text-right nowrap">
                                        <strong>{displayPrice price=$order_total_price currency=$currency->id}</strong>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="row">
    <div class="col-lg-12">
        <div class="panel">
            <h3><i class="icon-envelope"></i> {l s='Messages' mod='qrordersmanager'}</h3>
            {foreach from=$messages item=message}
                <div class="message-item">
                    <div class="message-avatar">
                        <div class="avatar-md">
                            <i class="icon-user icon-2x"></i>
                        </div>
                    </div>
                    <div class="message-body">
                        <span class="message-date">&nbsp;<i class="icon-calendar"></i>
                            {dateFormat date=$message['date_add']} -
                        </span>
                        <h4 class="message-item-heading">
                            {if ($message['elastname']|escape:'html':'UTF-8')}{$message['efirstname']|escape:'html':'UTF-8'}
                                {$message['elastname']|escape:'html':'UTF-8'}{else}{$message['cfirstname']|escape:'html':'UTF-8'} {$message['clastname']|escape:'html':'UTF-8'}
                            {/if}
                            {if ($message['private'] == 1)}
                                <span class="badge badge-info">{l s='Private' mod='qrordersmanager'}</span>
                            {/if}
                        </h4>
                        <p class="message-item-text">
                            {$message['message']|escape:'html':'UTF-8'|nl2br}
                        </p>
                    </div>
                </div>
            {/foreach}
        </div>
    </div>
</div>
