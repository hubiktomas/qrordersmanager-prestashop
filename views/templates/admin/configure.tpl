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

<div class="panel">
    <h3><i class="icon icon-book"></i> {l s='Documentation' mod='qrordersmanager'}</h3>
    <p>
        {l s='This module adds two new variables to all emails related to orders. These variables contain order
        reference encoded in a QR code to be scanned using this module.' mod='qrordersmanager'}
    </p>
    <p>
        {l s='The first one is [1]%s[/1], which contains QR code encoded as a HTML table, which allows you to scan
        it even though the user can have disabled displaying of images in his e-mail client.'
        sprintf='{qr_code_html}' tags=['<strong>'] mod='qrordersmanager'}
    </p>
    <p>
        {l s='The second is [1]%s[/1], which contains ASCII encoded QR code to be used in plain text e-mail
        templates.' sprintf='{qr_code_ascii}' tags=['<strong>'] mod='qrordersmanager'}
    </p>
    <p>
        {{l s='Feel free to add these variables to any template you wish in the %se-mail templates translation
        section%s.' mod='qrordersmanager'}|sprintf:"<a href=\"{$link->getAdminLink('AdminTranslations')}\">":'</a>'}
    </p>
</div>
