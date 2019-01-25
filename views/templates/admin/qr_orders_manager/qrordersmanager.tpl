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

<div class="panel" id ="qrordersmanager_search">
    <h3><i class="icon icon-search"></i> {l s='Find order' mod='qrordersmanager'}</h3>
    <div class="form-group">
        <div class="row" id="orderReferencePanel">
            <div class="col-lg-offset-1 col-lg-2">
                <label for="orderReference" class="control-label">{l s='Order reference' mod='qrordersmanager'}</label>
            </div>
            <div class="col-lg-5">
                <div class="input-group">
                    <div class="input-group-addon"><i class="icon icon-search"></i></div>
                    <input type="text" class="form-control" id="orderReferenceInput" name="orderReference" placeholder="">
                </div>
            </div>
            <div class="col-lg-4">
                <button type="submit" id="submitSearchButton" name="submitSearch" class="btn btn-default">
                    <i class="icon-search"></i> {l s='Search' mod='qrordersmanager'}
                </button>
                <button type="submit" id="startScanButton" name="startScan" class="btn btn-default">
                    <i class="icon-camera"></i> {l s='Scan' mod='qrordersmanager'}
                </button>
                <button type="submit" id="stopScanButton" name="stopScan" class="btn btn-default" style="display:none;">
                    <i class="icon-stop"></i> {l s='Stop' mod='qrordersmanager'}
                </button>
            </div>
        </div>
        <div class="row margin-top-10" id="videoPanel" style="display:none;">
            <div class="col-lg-12">
                <video id="video"></video>
            </div>
            <div class="col-lg-1">
            </div>
        </div>
        <div class="row margin-top-10" id="noVideoPanel" style="display:none;">
            <div class="col-lg-offset-3 col-lg-5">
                <p class="alert alert-danger">No video devices found.</p>
            </div>
            <div class="col-lg-4">
            </div>
        </div>
        <div class="row margin-top-10" id="scanSourcePanel" style="display:none;">
            <div class="col-lg-offset-1 col-lg-2">
                <label for="scanSource" class="control-label">{l s='Select scanning camera' mod='qrordersmanager'}</label>
            </div>
            <div class="col-lg-5">
                <div>
                    <select id="scanSourceSelect" name="scanSource"></select>
                </div>
            </div>
            <div class="col-lg-4">
            </div>
        </div>
    </div>
</div>

<div class="panel" id ="qrordersmanager_manage">
    <h3><i class="icon icon-credit-card"></i> {l s='Manage order' mod='qrordersmanager'}</h3>
    <div id="resultPanel">
        <div class="row">
            <div class="col-lg-12">
                <p class="alert alert-info">{l s='Find an order by reference code or scanning QR code to manage it.' mod='qrordersmanager'}</p>
            </div>
        </div>
    </div>
</div>

<script>
    var ajaxUrl = '{$link->getAdminLink('AdminQrOrdersManager')|escape:'javascript'}';
    var confirmationRequired = {if Configuration::get('QRORDERSMANAGER_CONFIRMATION')}true{else}false{/if};
</script>
