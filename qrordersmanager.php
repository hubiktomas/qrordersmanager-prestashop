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

defined('_PS_VERSION_') or die;

/**
 * QR Orders Manager main module class.
 */
class QrOrdersManager extends Module
{
    /**
     * @see Module::__construct()
     */
    public function __construct()
    {
        $this->name = 'qrordersmanager';
        $this->tab = 'administration';
        $this->version = '0.0.1';
        $this->author = 'Tomas Hubik';
        $this->author_uri = 'https://github.com/hubiktomas';
        $this->ps_versions_compliancy = array('min' => '1.5', 'max' => '1.6.9.9');
        $this->need_instance = 0;

        $this->bootstrap = true;
        
        parent::__construct();

        $this->displayName = $this->l("QR Orders Manager");
        $this->description = $this->l("Find orders by scanning QR codes and manage them in a simplified user interface.");
    }

    /**
     * @see Module::install()
     */
    public function install()
    {
        if (Shop::isFeatureActive()) {
            Shop::setContext(Shop::CONTEXT_ALL);
        }

        return
            parent::install() &&
            $this->installTab('AdminOrders', 'AdminQrOrdersManager', 'QR Orders Manager') &&
            Configuration::updateValue('QRORDERSMANAGER_CONFIRMATION', true);
    }

    /**
     * @see Module::uninstall()
     */
    public function uninstall()
    {
        return
            parent::uninstall() &&
            $this->uninstallTab('AdminQrOrdersManager') &&
            Configuration::deleteByName('QRORDERSMANAGER_CONFIRMATION');
    }
    
    /**
     * Adds tab to the admin menu.
     *
     * @param string $parent Parent tab class name
     * @param string $class_name Tab class name
     * @param string $name Tab label
     *
     * @return New tab id if successful, false otherwise
     */
    protected function installTab($parent, $class_name, $name)
    {
        $tab = new Tab();
        $tab->id_parent = (int)Tab::getIdFromClassName($parent);
        $tab->name = array();
        $langs = Language::getLanguages(true);
        foreach ($langs as $lang)
            $tab->name[$lang['id_lang']] = $name;
        $tab->class_name = $class_name;
        $tab->module = $this->name;
        $tab->active = 1;
        return $tab->add();
    }
    
    /**
     * Removes tab from the admin menu.
     *
     * @param string $class_name Tab class name
     *
     * @return True if successful, false otherwise
     */
    protected function uninstallTab($class_name)
    {
        $id_tab = (int)Tab::getIdFromClassName($class_name);
        $tab = new Tab((int)$id_tab);
        return $tab->delete();
    }

    /**
     * Handles the configuration page.
     *
     * @return string form html with eventual error/notification messages
     */
    public function getContent()
    {
        $output = "";
        
        // If values have been submitted in the form, process them
        if (Tools::isSubmit('submit' . $this->name)) {
            $fieldValues = $this->getConfigFieldValues();
            foreach (array_keys($fieldValues) as $key) {
                Configuration::updateValue($key, Tools::getValue($key));
            }
            $output .= $this->displayConfirmation($this->l("QR Orders Manager settings saved."));
        }
        
        return $output . $this->renderSettingsForm();
    }

    /**
     * Renders the settings form for the configuration page.
     *
     * @return string form html
     */
    public function renderSettingsForm()
    {
        // form fields
        $formFields = array(
            array(
                'form' => array(
                    'legend' => array(
                        'title' => $this->l("QR Orders Manager Settings"),
                        'icon' => 'icon-cog'
                    ),
                    'input' => array(
                         array(
                            'type' => 'switch',
                            'label' => $this->l('Require confirmation of order status change'),
                            'name' => 'QRORDERSMANAGER_CONFIRMATION',
                            'is_bool' => true,
                            'desc' => $this->l('Every time you will try to click "Delivered" button, a confirmation message will show up to avoid accidental changes especially on mobile phones.'),
                            'values' => array(
                                array(
                                    'id' => 'active_on',
                                    'value' => true,
                                    'label' => $this->l('Enabled')
                                ),
                                array(
                                    'id' => 'active_off',
                                    'value' => false,
                                    'label' => $this->l('Disabled')
                                )
                            ),
                        )
                    ),
                    'submit' => array(
                        'title' => $this->l("Save")
                    )
                )
            )
        );

        // set up form
        $helper = new HelperForm();

        $helper->module = $this;
        $helper->name_controller = $this->name;
        $helper->token = Tools::getAdminTokenLite('AdminModules');
        $helper->currentIndex = $this->context->link->getAdminLink('AdminModules', false)
            .'&configure='.$this->name.'&tab_module='.$this->tab.'&module_name='.$this->name;

        $defaultLang = (int)Configuration::get('PS_LANG_DEFAULT');
        $helper->default_form_language = $defaultLang;
        $helper->allow_employee_form_lang = $defaultLang;

        $helper->title = $this->displayName;
        $helper->show_toolbar = true;
        $helper->toolbar_scroll = true;
        $helper->submit_action = 'submit' . $this->name;
        $helper->toolbar_btn = array(
            'save' => array(
                'desc' => $this->l("Save"),
                'href' => AdminController::$currentIndex . '&configure=' . $this->name . '&save=' . $this->name . '&token=' . Tools::getAdminTokenLite('AdminModules')
            ),
            'back' => array(
                'desc' => $this->l("Back to List"),
                'href' => AdminController::$currentIndex . '&token=' . Tools::getAdminTokenLite('AdminModules')
            )
        );
        
        $helper->tpl_vars = array(
            'fields_value' => $this->getConfigFieldValues(),
            'languages' => $this->context->controller->getLanguages(),
            'id_language' => $this->context->language->id,
        );

        return $helper->generateForm($formFields);
    }

    /**
     * Loads module config parameters values.
     *
     * @return array array of config values
     */
    public function getConfigFieldValues()
    {
        return array(
            'QRORDERSMANAGER_CONFIRMATION' => Configuration::get('QRORDERSMANAGER_CONFIRMATION')
        );
    }
}
