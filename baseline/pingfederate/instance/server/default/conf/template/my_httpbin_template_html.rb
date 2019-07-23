<!DOCTYPE html>
#*
The server renders this HTML page in an end-user's browser when
needed authentication credentials may be obtained via HTTP Basic
Authentication or an HTML form.

Velocity variables (identified by the $ character) are generated
at runtime by the server.

The following variables are available on this page, but not used by default:

$entityId       - The entity ID (connection ID) of the SP Connection used in this SSO transaction
$connectionName - The name of the SP Connection used in this SSO transaction
$client_id      - The ID of the OAuth client used in this transaction
$spAdapterId    - The SP Adapter ID used in this transaction

It is recommended to sanitize the values that are displayed using $escape.escape() for example $escape.escape($client_id).

Change text or formatting as needed. Modifying Velocity statements
is not recommended as it may interfere with expected server behavior.
*#

<!-- template name: html.form.login.template.html -->

#set( $messageKeyPrefix = "html.form.login.template." )

<!-- Configurable default behavior for the Remember Username checkbox -->
#set ($enableCheckboxByDefault = false)
#if($rememberUsernameCookieExists)
    #set ($rememberUsernameChecked = "checked")
#else
    #if($enableCheckboxByDefault)
        <!-- allow the checkbox to be enabled by default -->
        #set ($rememberUsernameChecked = "checked")
    #else
        <!-- set the checkbox to unchecked -->
        #set ($rememberUsernameChecked = "")
    #end
#end


<html lang="$locale.getLanguage()" dir="ltr">
<head>
    <title>$templateMessages.getMessage($messageKeyPrefix, "title")</title>
    <base href="$CurrentPingFedBaseURL"/>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no"/>
    <meta http-equiv="x-ua-compatible" content="IE=edge" />
    <link rel="stylesheet" type="text/css" href="assets/css/main.css"/>
    #if($captchaEnabled)
        <script src='https://www.google.com/recaptcha/api.js' async defer></script>
    #end
</head>

<body onload="setFocus();isWebAuthnPlatformAuthenticatorAvailable();">

<div class="ping-container ping-signin login-template">

    <!--
    if there is a logo present in the 'company-logo' container,
    then 'has-logo' class should be added to 'ping-header' container.
    -->
    <div class="ping-header">
        <span class="company-logo"><!-- client company logo here --></span>
My Awesome httpbin<br> Sign-On
    </div>
    <!-- .ping-header -->

    <div class="ping-body-container">

        <div>
            <form method="POST" action="$url" autocomplete="off">

                <div class="ping-messages">
                    #if($authnMessageKey)
                        <div class="ping-error">$templateMessages.getMessage($authnMessageKey)</div>
                    #end
                    #if($errorMessageKey)
                        <div class="ping-error">$templateMessages.getMessage($messageKeyPrefix, $errorMessageKey)</div>
                    #end

                    ## Uncomment below to display any additional server error:
                    #*
                    #if($serverError)
                        <div class="ping-error">$serverError</div>
                    #end
                    *#
                </div>

                #if($altAuthSources.size() > 0)
                <div class="content-columns columns-2">
                    <div class="content-column column-1">

                        <div class="column-title">
                            $templateMessages.getMessage($messageKeyPrefix, "title")
                        </div>
                #end

                        <div class="ping-input-label">
                            $templateMessages.getMessage($messageKeyPrefix, "usernameTitle")
                        </div>
                        <div class="ping-input-container">
                            #if($usernameEditable)
                                <input id="username" type="text" size="36" name="$name" value="$username" autocorrect="off" autocapitalize="off" onKeyPress="return postOnReturn(event)"  /><!--#* Username value is explicitly HTML encoded in HtmlFormIdpAuthnAdapter *#-->
                            #else
                                <input id="username" type="text" size="36" name="$name" value="$username" disabled="disabled" autocorrect="off" autocapitalize="off" onKeyPress="return postOnReturn(event)"  /><!--#* Username value is explicitly HTML encoded in HtmlFormIdpAuthnAdapter *#-->
                            #end
                            <div class="place-bottom type-alert tooltip-text" id="username-text">
                                <div class="icon">!</div>
                                $templateMessages.getMessage($messageKeyPrefix, "missingField")
                            </div>
                        </div>

                        <div class="ping-input-label">
                            $templateMessages.getMessage($messageKeyPrefix, "passwordTitle")
                        </div>
                        <div class="ping-input-container password-container">
                            <input id="password" type="password" size="36" name="$pass" onKeyPress="return postOnReturn(event)" />
                            <div class="place-bottom type-alert tooltip-text" id="password-text">
                                <div class="icon">!</div>
                                $templateMessages.getMessage($messageKeyPrefix, "missingField")
                            </div>
                        </div>

                        #if($enableRememberUsername)
                            <label class="remember-username">
                                <div class="ping-checkbox-container stacked">
                                    <input id="rememberUsername" type="checkbox" name="$rememberUsername" $rememberUsernameChecked />
                                    $templateMessages.getMessage($messageKeyPrefix, "rememberUsernameTitle")
                                    <div class="icon"></div>
                                </div>
                            </label>
                        #end

                        #if($showMyDeviceCheckbox)
                            <label class="my-computer">
                                <div class="ping-checkbox-container stacked">
                                    <input id="myDevice" type="checkbox" name="$myDevice" $myDeviceChecked />
                                    $templateMessages.getMessage($messageKeyPrefix, "myDeviceTitle")
                                    <div class="icon"></div>
                                </div>
                            </label>
                        #end

                        <div class="ping-buttons">
                            <input type="hidden" name="$ok" value="" />
                            <input type="hidden" name="$cancel" value="" />

                            <a onclick="postOk();" class="ping-button normal allow" title="$templateMessages.getMessage($messageKeyPrefix, "signInButtonTitle")">
                            $templateMessages.getMessage($messageKeyPrefix, "signInButtonTitle")
                            </a>
                        </div><!-- .ping-buttons -->

                        #if($supportsPasswordChange || $supportsPasswordReset || $supportsUsernameRecovery)
                        <div class="ping-input-link ping-pass-change account-actions">
                            #if($supportsPasswordChange)
                            <a href="$changePasswordUrl" class="password-change">$templateMessages.getMessage($messageKeyPrefix, "changePassword")</a>
                            #end
                            #if($supportsPasswordChange && ($supportsPasswordReset || $supportsUsernameRecovery))
                            <span class="divider">|</span>
                            #end
                            #if($supportsPasswordReset)
                            <input type="hidden" name="$passwordReset" value=""/>
                            <a onclick="postForgotPassword();" class="forgot-password">$templateMessages.getMessage($messageKeyPrefix, "forgotPassword")</a>
                            #elseif($supportsUsernameRecovery)
                            <input type="hidden" name="$usernameRecovery" value=""/>
                            <a onclick="postRecoverUsername();" class="forgot-password">$templateMessages.getMessage($messageKeyPrefix, "recoverUsername")</a>
                            #end
                        </div>
                        #end

                        #if($registrationEnabled)
                        <div class="ping-register">
                            <input type="hidden" name="$registrationValue" value=""/>
                            $templateMessages.getMessage($messageKeyPrefix, "noAccountMessage") <a onclick="postRegistration();">$templateMessages.getMessage($messageKeyPrefix, "registerAccount")</a>
                        </div>
                        #end

                #if($altAuthSources.size() > 0)
                    </div>
                    <!-- column-1 -->

                    <div class="content-column column-2">
                        <div class="columns-separator">
                            <span>$templateMessages.getMessage($messageKeyPrefix, "columnsSeparator")</span>
                        </div>

                        <div class="column-title-2">
                            $templateMessages.getMessage($messageKeyPrefix, "loginWithButtonTitle")
                        </div>

                        <div class="social-media-container">
                            <input type="hidden" name="$alternateAuthnSystem" value=""/>
                            #foreach ($authSource in $altAuthSources)
                            #set( $htmlSafeAuthSource = $authSource.replaceAll("[^A-Za-z]+", "").toLowerCase() )
                                <div class="button-container" id='${htmlSafeAuthSource}-div'>
                                    <a onclick="postAlternateAuthnSystem('$authSource');" class="ping-button social-media $htmlSafeAuthSource" title='$authSource'>$authSource</a>
                                </div>
                            #end
                        </div>
                    </div>
                    <!-- column-2 -->

                </div>
                <!-- content-columns -->
                #end
                
                <!-- #recaptcha -->
                #if($captchaEnabled)
                    <div id="recaptcha"
                         class="g-recaptcha recaptcha"
                         data-badge="bottomright"
                         data-sitekey=$siteKey
                         data-callback="submitForm"
                         data-size="invisible"></div>
                #end

                <input type="hidden" name="$adapterIdField" id="$adapterIdField" value="$adapterId" />
            </form>
        </div><!-- .ping-body// blank div -->
        
    </div><!-- .ping-body-container -->

    <div class="ping-footer-container">
        <div class="ping-footer">
            <div class="ping-credits"></div>
            <div class="ping-copyright">$templateMessages.getMessage("global.footerMessage")</div>
        </div>
        <!-- .ping-footer -->
    </div>
    <!-- .ping-footer-container -->

</div><!-- .ping-container -->

<script type="text/javascript">

	function postForgotPassword() {

		document.forms[0]['$passwordReset'].value = 'clicked';
		document.forms[0].submit();
	}

	function postRecoverUsername() {
		var target = "$recoverUsernameUrl";
		document.forms[0].action = target;
        document.forms[0]['$usernameRecovery'].value = 'clicked';
		document.forms[0].submit();
	}

	function postAlternateAuthnSystem(system) {
	    var variants = ["Biometrics", "Windows Hello", "Face ID",  "Touch ID"];
	    if(variants.includes(system)) system = "FIDO";
	    document.forms[0]['$alternateAuthnSystem'].value = system;
	    document.forms[0].submit();
	}


	function postRegistration()
    {
        document.forms[0]['$registrationValue'].value = true;
        document.forms[0].submit();
    }

    function postOk() {
        if ($captchaEnabled) {
            grecaptcha.execute();
        }
        else {
            // remove error tips
            if (document.forms[0]['$name'].value !== '') {
                document.getElementById('username-text').className = 'place-bottom type-alert tooltip-text';
            }
            if (document.forms[0]['$pass'].value !== '') {
                document.getElementById('password-text').className = 'place-bottom type-alert tooltip-text';
            }
            // Add back
            if (document.forms[0]['$name'].value === '') {
                document.getElementById('username-text').className += ' show';
            }
            else if (document.forms[0]['$pass'].value === '') {
                document.getElementById('password-text').className += ' show';
            }
            else {
                submitForm()
            }
        }
    }

    function submitForm()
    {
        document.forms[0]['$ok'].value = 'clicked';
        document.forms[0].submit();
        if($captchaEnabled) {
            grecaptcha.reset();
        }
    }

    function postCancel() {
        document.forms[0]['$cancel'].value = 'clicked';
        document.forms[0].submit();
    }

    function postOnReturn(e) {
        var keycode;
        if (window.event) keycode = window.event.keyCode;
        else if (e) keycode = e.which;
        else return true;

        if (keycode == 13) {
            postOk();
            return false;
        } else {
            return true;
        }
    }

    function setFocus() {
        var platform = navigator.platform;
        if (platform != null && platform.indexOf("iPhone") == -1) {
            #if($loginFailed || ($rememberUsernameCookieExists && $enableRememberUsername) || $isChainedUsernameAvailable)
                document.getElementById('password').focus();
            #else
                document.getElementById('username').focus();
            #end
        }
    }

    function setMobile(mobile) {
        var className = ' mobile',
            hasClass = (bodyTag.className.indexOf(className) !== -1);

        if (mobile && !hasClass) {
            bodyTag.className += className;

        } else if (!mobile && hasClass) {
            bodyTag.className = bodyTag.className.replace(className, '');
        }

        #if($enableRememberUsername)
            checkbox.checked = mobile || remember;
        #end

        <!-- Check if this is the PingOne Mobile App -->
        #if($HttpServletRequest.getHeader('X-Ping-Client-Version'))
            if (mobile) {
                bodyTag.className += ' embedded';
            }
        #end
    }

    function getScreenWidth() {
        return (window.outerHeight) ? window.outerWidth : document.body.clientWidth;
    }

    var bodyTag = document.getElementsByTagName('body')[0],
        width = getScreenWidth(),
        remember = $rememberUsernameCookieExists && $enableRememberUsername;

    // set container
    #if($altAuthSources.size() > 0)
        bodyTag.className += ' columns-layout';
    #end

    #if($enableRememberUsername)
        var checkbox = document.getElementById('rememberUsername');
    #end

    if (/Android|webOS|iPhone|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)) {
        setMobile(true);
    } else {
        setMobile((width <= 480));
        window.onresize = function() {
            width = getScreenWidth();
            setMobile((width <= 480));
        }
    }

    function IsWebAuthnSupported() {
        if (!window.PublicKeyCredential) {

            console.log("Web Authentication API is not supported on this browser.");
            return false;
        }

        return true;
    }

    function isWebAuthnPlatformAuthenticatorAvailable() {

        theElement = document.getElementById("biometrics-div");
        if(theElement)
            theElement.style.display = "none";

        theElement = document.getElementById("windowshello-div");
        if(theElement)
             theElement.style.display = "none";

        theElement = document.getElementById("faceid-div");
        if(theElement)
            theElement.style.display = "none";

        theElement = document.getElementById("touchid-div");
        if(theElement)
            theElement.style.display = "none";

        var timer;

        var p1 = new Promise(function(resolve) {
            timer = setTimeout(function() {
                console.log("isWebAuthnPlatformAuthenticatorAvailable - Timeout");
                resolve(false);
            }, 300);
        });

        var p2 = new Promise(function(resolve) {

            if (IsWebAuthnSupported() && window.PublicKeyCredential.isUserVerifyingPlatformAuthenticatorAvailable) {

                resolve(
                    window.PublicKeyCredential.isUserVerifyingPlatformAuthenticatorAvailable().catch(function(err) {
                        console.log(err);
                        return false;
                    }));
            }
            else {
                resolve(false);
            }
        });

        return Promise.race([p1, p2]).then(function (res) {
            clearTimeout(timer);
            console.log("isWebAuthnPlatformAuthenticatorAvailable - " +  res);

            if(res) {
                 theElement = document.getElementById("biometrics-div");
                 if(theElement)
                     theElement.style.display = "block";

                 theElement = document.getElementById("windowshello-div");
                 if(theElement)
                     theElement.style.display = "block";

                 theElement = document.getElementById("faceid-div");
                 if(theElement)
                     theElement.style.display = "block";

                 theElement = document.getElementById("touchid-div");
                 if(theElement)
                     theElement.style.display = "block";
            }

            return res;
        });
    }
</script>

</body>
</html>
