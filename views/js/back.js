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

$(document).ready(function() {
    let selectedDeviceId;
    const codeReader = new ZXing.BrowserQRCodeReader();
    const orderReferenceInput = $("#orderReferenceInput");
    const startScanButton = $("#startScanButton");
    const stopScanButton = $("#stopScanButton");
    const submitSearchButton = $("#submitSearchButton");
    const scanSourceSelect = $("#scanSourceSelect");
    const scanSourcePanel = $("#scanSourcePanel");
    const videoPanel = $("#videoPanel");
    const noVideoPanel = $("#noVideoPanel");
    const resultPanel = $("#resultPanel");

    // Start scanning on start button click
    startScanButton.click(startScan);

    // Stop scanning on stop button click
    stopScanButton.click(stopScan);

    // Find order on submit button click
    submitSearchButton.click(function() {
        findOrder(orderReferenceInput.val(), ajaxUrl, resultPanel);
    });

    // Change camera ID and restart scanning on camera select change
    scanSourceSelect.change(function() {
        selectedDeviceId = this.value == -1 ? undefined : this.value;
        codeReader.reset();
        startScanning(selectedDeviceId);
    });

    /**
     * Shows all scan related elements and starts scanning.
     */
    function startScan() {
        codeReader.getVideoInputDevices().then((videoInputDevices) => {
            startScanButton.hide();
            stopScanButton.show();
            scanSourceSelect.empty();

            // If we have at least one camera, we can continue
            if (videoInputDevices.length > 0) {
                // Value -1 is converted to undefined if selected,
                // which means that main (environment facing) camera will be used
                scanSourceSelect.append(new Option('Default camera', -1));

                // Add cameras to the camera selector and try to match the one previously selected
                let selectedDeviceIdFound = false;
                videoInputDevices.forEach((element) => {
                    scanSourceSelect.append(new Option(
                        element.label,
                        element.deviceId,
                        selectedDeviceId == element.deviceId,
                        selectedDeviceId == element.deviceId
                    ));
                    if (selectedDeviceId == element.deviceId) {
                        selectedDeviceIdFound = true;
                    }
                });

                // Overwrite previously selected area with undefined if it does not exist anymore
                if (!selectedDeviceIdFound) {
                    selectedDeviceId = undefined;
                }

                // Show camera selector if we have more than one camera
                if (videoInputDevices.length > 1) {
                    scanSourcePanel.slideDown();
                }

                startScanning(selectedDeviceId);
            } else {
                noVideoPanel.show();
            }
        }).catch((e) => {
            resultPanel.html(getErrorHtml("FATAL ERROR: " + e.message));
            console.error(e);
        });
    }

    /**
     * Stops scanning and hides all related elements.
     */
    function stopScan() {
        scanSourcePanel.slideUp();
        videoPanel.slideUp();
        noVideoPanel.hide();
        codeReader.reset();
        scanSourceSelect.empty();
        startScanButton.show();
        stopScanButton.hide();
    }

    /**
     * Starts continuous scanning through camera until a QR code is recognized.
     *
     * @param string devideId id of camera to use for scanning.
     */
    function startScanning(deviceId) {
        videoPanel.slideDown();
        codeReader.decodeFromInputVideoDevice(deviceId, 'video').then((result) => {
            // Stop scanning if a QR code is recognized
            stopScan();
            orderReferenceInput.val(result.text);
            findOrder(result.text, ajaxUrl, resultPanel);
        }).catch((e) => {
            resultPanel.html(getErrorHtml("FATAL ERROR: " + e.message));
            console.error(e);
        });
    }
});

/**
 * Finds order based on order reference and sets manage order section using AJAX.
 *
 * @param string orderReference order reference to search for
 * @param string ajaxUrl ajax URL for call
 * @param object resultPanel element, where to set HTML of the response
 */
function findOrder(orderReference, ajaxUrl, resultPanel) {
    resultPanel.html(getLoaderHtml("Loading order info"));
    $.ajax({
        type: 'POST',
        cache: false,
        dataType: 'html',
        url: ajaxUrl,
        data: {
            ajax: true,
            action: 'getOrder',
            orderReference: orderReference
        }
    }).done(function (data) {
        resultPanel.html(data);
    }).fail(function (jqXHR, error) {
        resultPanel.html(getErrorHtml("FATAL ERROR: AJAX request failed."));
        console.error(error);
    });
}

/**
 * Finds order based on order reference, updates its status to delivered and sets manage order section using AJAX.
 *
 * @param string orderReference order reference to mark as delivered
 * @param string ajaxUrl ajax URL for call
 * @param object resultPanel element, where to set HTML of the response
 */
function markOrderAsDelivered(orderReference, ajaxUrl, resultPanel) {
    $.ajax({
        type: 'POST',
        cache: false,
        dataType: 'html',
        url: ajaxUrl,
        data: {
            ajax: true,
            action: 'setOrderDelivered',
            orderReference: orderReference
        }
    }).done(function (data) {
        resultPanel.html(data);
    }).fail(function (jqXHR, error) {
        resultPanel.html(getErrorHtml("FATAL ERROR: AJAX request failed."));
        console.error(error);
    });
}

/**
 * Gets HTML code of a loader object.
 *
 * @param string loaderText text to be shown under the loader
 *
 * @return string loader HTML code
 */
function getLoaderHtml(loaderText) {
    return '<div id="loader"><i class="process-icon-loading"></i>' + loaderText + '</div>';
}

/**
 * Wraps error message to HTML to be dislayed in the user interface
 *
 * @param string errorText error message to be displayed
 *
 * @return string HTML code with the error message
 */
function getErrorHtml(errorText) {
    return '<div class="row"><div class="col-lg-12"><p class="alert alert-danger">' + errorText + '</p></div></div>';
}