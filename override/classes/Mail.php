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

require_once(_PS_MODULE_DIR_ . 'qrordersmanager/lib/phpqrcode/qrlib.php');

class Mail extends MailCore
{
    /**
     * Send email.
     *
     * @param int $id_lang language ID of the email (to translate the template)
     * @param string $template the name of template
     * @param string $subject subject of the email
     * @param string $template_vars template variables for the email
     * @param string|array $to to email
     * @param string|array $to_name to name
     * @param string $from from email
     * @param string $from_name from name
     * @param array $file_attachment array with three parameters (content, mime and name) - you can use an array of arrays to attach multiple files
     * @param bool $mode_smtp SMTP mode (deprecated)
     * @param string $template_path template path
     * @param bool $die die after error
     * @param int $id_shop shop ID
     * @param string|array $bcc bcc recipient(s) (email address)
     * @param string $reply_to email address for setting the Reply-To header
     * 
     * @return bool|int false if the sending failed completly, otherwise number of successfull recipients
     */
    public static function Send(
        $id_lang,
        $template,
        $subject,
        $template_vars,
        $to,
        $to_name = null,
        $from = null,
        $from_name = null,
        $file_attachment = null,
        $mode_smtp = null,
        $template_path = _PS_MAIL_DIR_,
        $die = false,
        $id_shop = null,
        $bcc = null,
        $reply_to = null
    ) {
        // Try to get Order object from current context
        $cart = Context::getContext()->cart;
        $order = false;
        if (Validate::isLoadedObject($cart)) {
            $order_id = Order::getOrderByCartId((int)($cart->id));
            if ($order_id) {
                $order = new Order($order_id);
            }
        }
        // If there is a valid Order in the context, add QR encoded order reference to the e-mail templates
        if (Validate::isLoadedObject($order)) {
            $qrData = array(
                '{qr_code_html}' => Mail::generateQrHtml($order->getUniqReference()),
                '{qr_code_ascii}' => Mail::generateQrAscii($order->getUniqReference())
            );
            if (is_array($template_vars)) {
                $template_vars = array_merge($qrData, $template_vars);
            } else {
                $template_vars = $qrData;
            }
        }

        return parent::Send(
            $id_lang,
            $template,
            $subject,
            $template_vars,
            $to,
            $to_name,
            $from,
            $from_name,
            $file_attachment,
            $mode_smtp,
            $template_path,
            $die,
            $id_shop,
            $bcc,
            $reply_to
        );
    }

    /**
     * Generate HTML table encoded QR code with given string.
     *
     * @param string $text text to encode
     *
     * @return string HTML encoded QR code
     */
    public static function generateQrHtml($text)
    {
        $blackPixel = "<td style='width: 8px; height: 8px; border: 0; padding: 0; background-color:black;'></td>\n";
        $whitePixel = "<td style='width: 8px; height: 8px; border: 0; padding: 0; background-color:white;'></td>\n";
        $qr = QRcode::text($text, false, "H");
        $qrwidth = Tools::strlen($qr[0]);
        foreach ($qr as &$qrline) {
            $qrline = strtr($qrline, array("0" => $whitePixel, "1" => $blackPixel));
        }
        $qr = join(str_repeat($whitePixel, 2) . "</tr><tr>\n" . str_repeat($whitePixel, 2), $qr);
        $qr = "<table style='border-collapse: collapse; border-spacing: 0; margin: 0px auto;'>\n" .
            "<tr>\n" .
            str_repeat($whitePixel, $qrwidth + 4) .
            "</tr><tr>\n" .
            str_repeat($whitePixel, $qrwidth + 4) .
            "</tr><tr>\n" .
            str_repeat($whitePixel, 2) . $qr . str_repeat($whitePixel, 2) .
            "</tr><tr>\n" .
            str_repeat($whitePixel, $qrwidth + 4) .
            "</tr><tr>\n" .
            str_repeat($whitePixel, $qrwidth + 4) .
            "</tr>\n" .
            "</table>";
        return $qr;
    }

    /**
     * Generate ASCII encoded QR code with given string.
     *
     * @param string $text text to encode
     *
     * @return string ASCII encoded QR code
     */
    public static function generateQrAscii($text)
    {
        $qr = QRcode::text($text, false, "H");
        $asciiqr = "";
        for ($i = 0; $i < count($qr); $i += 2) {
            for ($j = 0; $j < Tools::strlen($qr[$i]); $j++) {
                if ($qr[$i][$j] == 1) {
                    if (array_key_exists($i + 1, $qr) && $qr[$i + 1][$j] == 1) {
                        $asciiqr .= "█";
                    } else {
                        $asciiqr .= "▀";
                    }
                } else {
                    if (array_key_exists($i + 1, $qr) && $qr[$i + 1][$j] == 1) {
                        $asciiqr .= "▄";
                    } else {
                        $asciiqr .= " ";
                    }
                }
            }
            $asciiqr .= "\n";
        }
        return $asciiqr;
    }
}
