
# Copyright 2006 ThoughtWorks, Inc
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

# -----------------
# Original code by Aslak Hellesoy and Darren Hobbs
# This file has been automatically generated via XSL
# -----------------

require 'net/http'
require 'uri'
require 'cgi'

# Defines an object that runs Selenium commands.
# 
# ===Element Locators
# Element Locators tell Selenium which HTML element a command refers to.
# The format of a locator is:
# <em>locatorType</em><b>=</b><em>argument</em>
# We support the following strategies for locating elements:
# 
# *    <b>identifier</b>=<em>id</em>::
#     Select the element with the specified @id attribute. If no match is
#     found, select the first element whose @name attribute is <em>id</em>.
#     (This is normally the default; see below.)
# *    <b>id</b>=<em>id</em>::
#     Select the element with the specified @id attribute.
# *    <b>name</b>=<em>name</em>::
#     Select the first element with the specified @name attribute.
# 
#     *    username
#     *    name=username
#     
#     
# 
#     The name may optionally be followed by one or more <em>element-filters</em>, separated from the name by whitespace.  If the <em>filterType</em> is not specified, <b>value</b> is assumed.
# 
#     *    name=flavour value=chocolate
#     
#     
# *    <b>dom</b>=<em>javascriptExpression</em>::
#     
#         Find an element by evaluating the specified string.  This allows you to traverse the HTML Document Object
#         Model using JavaScript.  Note that you must not return a value in this string; simply make it the last expression in the block.
#         *    dom=document.forms['myForm'].myDropdown
#         *    dom=document.images[56]
#         *    dom=function foo() { return document.links[1]; }; foo();
#         
#         
#     
# *    <b>xpath</b>=<em>xpathExpression</em>::
#     Locate an element using an XPath expression.
#     *    xpath=//img[@alt='The image alt text']
#     *    xpath=//table[@id='table1']//tr[4]/td[2]
#     
#     
# *    <b>link</b>=<em>textPattern</em>::
#     Select the link (anchor) element which contains text matching the
#     specified <em>pattern</em>.
#     *    link=The link text
#     
#     
# *    <b>css</b>=<em>cssSelectorSyntax</em>::
#     Select the element using css selectors. Please refer to CSS2 selectors, CSS3 selectors for more information. You can also check the TestCssLocators test in the selenium test suite for an example of usage, which is included in the downloaded selenium core package.
#     *    css=a[href="#id3"]
#     *    css=span#firstChild + span
#     
#     
# 
#     Currently the css selector locator supports all css1, css2 and css3 selectors except namespace in css3, some pseudo classes(:nth-of-type, :nth-last-of-type, :first-of-type, :last-of-type, :only-of-type, :visited, :hover, :active, :focus, :indeterminate) and pseudo elements(::first-line, ::first-letter, ::selection, ::before, ::after). 
# 
# 
# Without an explicit locator prefix, Selenium uses the following default
# strategies:
# 
# *    <b>dom</b>, for locators starting with "document."
# *    <b>xpath</b>, for locators starting with "//"
# *    <b>identifier</b>, otherwise
# 
# ===Element FiltersElement filters can be used with a locator to refine a list of candidate elements.  They are currently used only in the 'name' element-locator.
# Filters look much like locators, ie.
# <em>filterType</em><b>=</b><em>argument</em>Supported element-filters are:
# <b>value=</b><em>valuePattern</em>
# 
# Matches elements based on their values.  This is particularly useful for refining a list of similarly-named toggle-buttons.<b>index=</b><em>index</em>
# 
# Selects a single element based on its position in the list (offset from zero).===String-match Patterns
# Various Pattern syntaxes are available for matching string values:
# 
# *    <b>glob:</b><em>pattern</em>::
#     Match a string against a "glob" (aka "wildmat") pattern. "Glob" is a
#     kind of limited regular-expression syntax typically used in command-line
#     shells. In a glob pattern, "*" represents any sequence of characters, and "?"
#     represents any single character. Glob patterns match against the entire
#     string.
# *    <b>regexp:</b><em>regexp</em>::
#     Match a string using a regular-expression. The full power of JavaScript
#     regular-expressions is available.
# *    <b>exact:</b><em>string</em>::
#     Match a string exactly, verbatim, without any of that fancy wildcard
#     stuff.
# 
# 
# If no pattern prefix is specified, Selenium assumes that it's a "glob"
# pattern.
# 
# 
module Selenium

    class SeleniumDriver
        include Selenium
    
        def initialize(server_host, server_port, browserStartCommand, browserURL, timeout=30000)
            @server_host = server_host
            @server_port = server_port
            @browserStartCommand = browserStartCommand
            @browserURL = browserURL
            @timeout = timeout
        end
        
        def to_s
            "SeleniumDriver"
        end

        def start()
            result = get_string("getNewBrowserSession", [@browserStartCommand, @browserURL])
            @session_id = result
        end
        
        def stop()
            do_command("testComplete", [])
            @session_id = nil
        end

        def do_command(verb, args)
            timeout(@timeout) do
                http = Net::HTTP.new(@server_host, @server_port)
                command_string = '/selenium-server/driver/?cmd=' + CGI::escape(verb)
                args.length.times do |i|
                    arg_num = (i+1).to_s
                    command_string = command_string + "&" + arg_num + "=" + CGI::escape(args[i].to_s)
                end
                if @session_id != nil
                    command_string = command_string + "&sessionId=" + @session_id.to_s
                end
                #print "Requesting --->" + command_string + "\n"
                response, result = http.get(command_string)
                #print "RESULT: " + result + "\n\n"
                if (result[0..1] != "OK")
                    raise SeleniumCommandError, result
                end
                return result
            end
        end
        
        def get_string(verb, args)
            result = do_command(verb, args)
            return result[3..result.length]
        end
        
        def get_string_array(verb, args)
            csv = get_string(verb, args)
            token = ""
            tokens = []
            escape = false
            csv.split(//).each do |letter|
                if escape
                    token = token + letter
                    escape = false
                    next
                end
                if (letter == '\\')
                    escape = true
                elsif (letter == ',')
                    tokens.push(token)
                    token = ""
                else
                    token = token + letter
                end
            end
            tokens.push(token)
            return tokens
        end
    
        def get_number(verb, args)
            # Is there something I need to do here?
            return get_string(verb, args)
        end
        
        def get_number_array(verb, args)
            # Is there something I need to do here?
            return get_string_array(verb, args)
        end
    
        def get_boolean(verb, args)
            boolstr = get_string(verb, args)
            if ("true" == boolstr)
                return true
            end
            if ("false" == boolstr)
                return false
            end
            raise ValueError, "result is neither 'true' nor 'false': " + boolstr
        end
        
        def get_boolean_array(verb, args)
            boolarr = get_string_array(verb, args)
            boolarr.length.times do |i|
                if ("true" == boolstr)
                    boolarr[i] = true
                    next
                end
                if ("false" == boolstr)
                    boolarr[i] = false
                    next
                end
                raise ValueError, "result is neither 'true' nor 'false': " + boolarr[i]
            end
            return boolarr
        end



        # Clicks on a link, button, checkbox or radio button. If the click action
        # causes a new page to load (like a link usually does), call
        # waitForPageToLoad.
        #
        # 'locator' is an element locator
        def click(locator)
            do_command("click", [locator,])
        end


        # Double clicks on a link, button, checkbox or radio button. If the double click action
        # causes a new page to load (like a link usually does), call
        # waitForPageToLoad.
        #
        # 'locator' is an element locator
        def double_click(locator)
            do_command("doubleClick", [locator,])
        end


        # Clicks on a link, button, checkbox or radio button. If the click action
        # causes a new page to load (like a link usually does), call
        # waitForPageToLoad.
        #
        # 'locator' is an element locator
        # 'coordString' is specifies the x,y position (i.e. - 10,20) of the mouse      event relative to the element returned by the locator.
        def click_at(locator,coordString)
            do_command("clickAt", [locator,coordString,])
        end


        # Doubleclicks on a link, button, checkbox or radio button. If the action
        # causes a new page to load (like a link usually does), call
        # waitForPageToLoad.
        #
        # 'locator' is an element locator
        # 'coordString' is specifies the x,y position (i.e. - 10,20) of the mouse      event relative to the element returned by the locator.
        def double_click_at(locator,coordString)
            do_command("doubleClickAt", [locator,coordString,])
        end


        # Explicitly simulate an event, to trigger the corresponding "on<em>event</em>"
        # handler.
        #
        # 'locator' is an element locator
        # 'eventName' is the event name, e.g. "focus" or "blur"
        def fire_event(locator,eventName)
            do_command("fireEvent", [locator,eventName,])
        end


        # Simulates a user pressing and releasing a key.
        #
        # 'locator' is an element locator
        # 'keySequence' is Either be a string("\" followed by the numeric keycode  of the key to be pressed, normally the ASCII value of that key), or a single  character. For example: "w", "\119".
        def key_press(locator,keySequence)
            do_command("keyPress", [locator,keySequence,])
        end


        # Press the shift key and hold it down until doShiftUp() is called or a new page is loaded.
        #
        def shift_key_down()
            do_command("shiftKeyDown", [])
        end


        # Release the shift key.
        #
        def shift_key_up()
            do_command("shiftKeyUp", [])
        end


        # Press the meta key and hold it down until doMetaUp() is called or a new page is loaded.
        #
        def meta_key_down()
            do_command("metaKeyDown", [])
        end


        # Release the meta key.
        #
        def meta_key_up()
            do_command("metaKeyUp", [])
        end


        # Press the alt key and hold it down until doAltUp() is called or a new page is loaded.
        #
        def alt_key_down()
            do_command("altKeyDown", [])
        end


        # Release the alt key.
        #
        def alt_key_up()
            do_command("altKeyUp", [])
        end


        # Press the control key and hold it down until doControlUp() is called or a new page is loaded.
        #
        def control_key_down()
            do_command("controlKeyDown", [])
        end


        # Release the control key.
        #
        def control_key_up()
            do_command("controlKeyUp", [])
        end


        # Simulates a user pressing a key (without releasing it yet).
        #
        # 'locator' is an element locator
        # 'keySequence' is Either be a string("\" followed by the numeric keycode  of the key to be pressed, normally the ASCII value of that key), or a single  character. For example: "w", "\119".
        def key_down(locator,keySequence)
            do_command("keyDown", [locator,keySequence,])
        end


        # Simulates a user releasing a key.
        #
        # 'locator' is an element locator
        # 'keySequence' is Either be a string("\" followed by the numeric keycode  of the key to be pressed, normally the ASCII value of that key), or a single  character. For example: "w", "\119".
        def key_up(locator,keySequence)
            do_command("keyUp", [locator,keySequence,])
        end


        # Simulates a user hovering a mouse over the specified element.
        #
        # 'locator' is an element locator
        def mouse_over(locator)
            do_command("mouseOver", [locator,])
        end


        # Simulates a user moving the mouse pointer away from the specified element.
        #
        # 'locator' is an element locator
        def mouse_out(locator)
            do_command("mouseOut", [locator,])
        end


        # Simulates a user pressing the mouse button (without releasing it yet) on
        # the specified element.
        #
        # 'locator' is an element locator
        def mouse_down(locator)
            do_command("mouseDown", [locator,])
        end


        # Simulates a user pressing the mouse button (without releasing it yet) on
        # the specified element.
        #
        # 'locator' is an element locator
        # 'coordString' is specifies the x,y position (i.e. - 10,20) of the mouse      event relative to the element returned by the locator.
        def mouse_down_at(locator,coordString)
            do_command("mouseDownAt", [locator,coordString,])
        end


        # Simulates a user pressing the mouse button (without releasing it yet) on
        # the specified element.
        #
        # 'locator' is an element locator
        def mouse_up(locator)
            do_command("mouseUp", [locator,])
        end


        # Simulates a user pressing the mouse button (without releasing it yet) on
        # the specified element.
        #
        # 'locator' is an element locator
        # 'coordString' is specifies the x,y position (i.e. - 10,20) of the mouse      event relative to the element returned by the locator.
        def mouse_up_at(locator,coordString)
            do_command("mouseUpAt", [locator,coordString,])
        end


        # Simulates a user pressing the mouse button (without releasing it yet) on
        # the specified element.
        #
        # 'locator' is an element locator
        def mouse_move(locator)
            do_command("mouseMove", [locator,])
        end


        # Simulates a user pressing the mouse button (without releasing it yet) on
        # the specified element.
        #
        # 'locator' is an element locator
        # 'coordString' is specifies the x,y position (i.e. - 10,20) of the mouse      event relative to the element returned by the locator.
        def mouse_move_at(locator,coordString)
            do_command("mouseMoveAt", [locator,coordString,])
        end


        # Sets the value of an input field, as though you typed it in.
        # 
        # Can also be used to set the value of combo boxes, check boxes, etc. In these cases,
        # value should be the value of the option selected, not the visible text.
        # 
        #
        # 'locator' is an element locator
        # 'value' is the value to type
        def type(locator,value)
            do_command("type", [locator,value,])
        end


        # Set execution speed (i.e., set the millisecond length of a delay which will follow each selenium operation).  By default, there is no such delay, i.e.,
        # the delay is 0 milliseconds.
        #
        # 'value' is the number of milliseconds to pause after operation
        def set_speed(value)
            do_command("setSpeed", [value,])
        end


        # Get execution speed (i.e., get the millisecond length of the delay following each selenium operation).  By default, there is no such delay, i.e.,
        # the delay is 0 milliseconds.
        # 
        # See also setSpeed.
        #
        def get_speed()
            do_command("getSpeed", [])
        end


        # Check a toggle-button (checkbox/radio)
        #
        # 'locator' is an element locator
        def check(locator)
            do_command("check", [locator,])
        end


        # Uncheck a toggle-button (checkbox/radio)
        #
        # 'locator' is an element locator
        def uncheck(locator)
            do_command("uncheck", [locator,])
        end


        # Select an option from a drop-down using an option locator.
        # 
        # 
        # Option locators provide different ways of specifying options of an HTML
        # Select element (e.g. for selecting a specific option, or for asserting
        # that the selected option satisfies a specification). There are several
        # forms of Select Option Locator.
        # 
        # *    <b>label</b>=<em>labelPattern</em>::
        #     matches options based on their labels, i.e. the visible text. (This
        #     is the default.)
        #     *    label=regexp:^[Oo]ther
        #     
        #     
        # *    <b>value</b>=<em>valuePattern</em>::
        #     matches options based on their values.
        #     *    value=other
        #     
        #     
        # *    <b>id</b>=<em>id</em>::
        #     matches options based on their ids.
        #     *    id=option1
        #     
        #     
        # *    <b>index</b>=<em>index</em>::
        #     matches an option based on its index (offset from zero).
        #     *    index=2
        #     
        #     
        # 
        # 
        # If no option locator prefix is provided, the default behaviour is to match on <b>label</b>.
        # 
        # 
        #
        # 'selectLocator' is an element locator identifying a drop-down menu
        # 'optionLocator' is an option locator (a label by default)
        def select(selectLocator,optionLocator)
            do_command("select", [selectLocator,optionLocator,])
        end


        # Add a selection to the set of selected options in a multi-select element using an option locator.
        # 
        # @see #doSelect for details of option locators
        #
        # 'locator' is an element locator identifying a multi-select box
        # 'optionLocator' is an option locator (a label by default)
        def add_selection(locator,optionLocator)
            do_command("addSelection", [locator,optionLocator,])
        end


        # Remove a selection from the set of selected options in a multi-select element using an option locator.
        # 
        # @see #doSelect for details of option locators
        #
        # 'locator' is an element locator identifying a multi-select box
        # 'optionLocator' is an option locator (a label by default)
        def remove_selection(locator,optionLocator)
            do_command("removeSelection", [locator,optionLocator,])
        end


        # Submit the specified form. This is particularly useful for forms without
        # submit buttons, e.g. single-input "Search" forms.
        #
        # 'formLocator' is an element locator for the form you want to submit
        def submit(formLocator)
            do_command("submit", [formLocator,])
        end


        # Opens an URL in the test frame. This accepts both relative and absolute
        # URLs.
        # 
        # The "open" command waits for the page to load before proceeding,
        # ie. the "AndWait" suffix is implicit.
        # 
        # <em>Note</em>: The URL must be on the same domain as the runner HTML
        # due to security restrictions in the browser (Same Origin Policy). If you
        # need to open an URL on another domain, use the Selenium Server to start a
        # new browser session on that domain.
        #
        # 'url' is the URL to open; may be relative or absolute
        def open(url)
            do_command("open", [url,])
        end


        # Opens a popup window (if a window with that ID isn't already open).
        # After opening the window, you'll need to select it using the selectWindow
        # command.
        # 
        # This command can also be a useful workaround for bug SEL-339.  In some cases, Selenium will be unable to intercept a call to window.open (if the call occurs during or before the "onLoad" event, for example).
        # In those cases, you can force Selenium to notice the open window's name by using the Selenium openWindow command, using
        # an empty (blank) url, like this: openWindow("", "myFunnyWindow").
        # 
        #
        # 'url' is the URL to open, which can be blank
        # 'windowID' is the JavaScript window ID of the window to select
        def open_window(url,windowID)
            do_command("openWindow", [url,windowID,])
        end


        # Selects a popup window; once a popup window has been selected, all
        # commands go to that window. To select the main window again, use null
        # as the target.
        # 
        # Selenium has several strategies for finding the window object referred to by the "windowID" parameter.
        # 1.) if windowID is null, then it is assumed the user is referring to the original window instantiated by the browser).
        # 2.) if the value of the "windowID" parameter is a JavaScript variable name in the current application window, then it is assumed
        # that this variable contains the return value from a call to the JavaScript window.open() method.
        # 3.) Otherwise, selenium looks in a hash it maintains that maps string names to window objects.  Each of these string 
        # names matches the second parameter "windowName" past to the JavaScript method  window.open(url, windowName, windowFeatures, replaceFlag)
        # (which selenium intercepts).
        # If you're having trouble figuring out what is the name of a window that you want to manipulate, look at the selenium log messages
        # which identify the names of windows created via window.open (and therefore intercepted by selenium).  You will see messages
        # like the following for each window as it is opened:
        # <tt>debug: window.open call intercepted; window ID (which you can use with selectWindow()) is "myNewWindow"</tt>
        # In some cases, Selenium will be unable to intercept a call to window.open (if the call occurs during or before the "onLoad" event, for example).
        # (This is bug SEL-339.)  In those cases, you can force Selenium to notice the open window's name by using the Selenium openWindow command, using
        # an empty (blank) url, like this: openWindow("", "myFunnyWindow").
        # 
        #
        # 'windowID' is the JavaScript window ID of the window to select
        def select_window(windowID)
            do_command("selectWindow", [windowID,])
        end


        # Selects a frame within the current window.  (You may invoke this command
        # multiple times to select nested frames.)  To select the parent frame, use
        # "relative=parent" as a locator; to select the top frame, use "relative=top".
        # 
        # You may also use a DOM expression to identify the frame you want directly,
        # like this: <tt>dom=frames["main"].frames["subframe"]</tt>
        # 
        #
        # 'locator' is an element locator identifying a frame or iframe
        def select_frame(locator)
            do_command("selectFrame", [locator,])
        end


        # Return the contents of the log.
        # 
        # This is a placeholder intended to make the code generator make this API
        # available to clients.  The selenium server will intercept this call, however,
        # and return its recordkeeping of log messages since the last call to this API.
        # Thus this code in JavaScript will never be called.
        # The reason I opted for a servercentric solution is to be able to support
        # multiple frames served from different domains, which would break a
        # centralized JavaScript logging mechanism under some conditions.
        # 
        #
        def get_log_messages()
            return get_string("getLogMessages", [])
        end


        # Determine whether current/locator identify the frame containing this running code.
        # 
        # This is useful in proxy injection mode, where this code runs in every
        # browser frame and window, and sometimes the selenium server needs to identify
        # the "current" frame.  In this case, when the test calls selectFrame, this
        # routine is called for each frame to figure out which one has been selected.
        # The selected frame will return true, while all others will return false.
        # 
        #
        # 'currentFrameString' is starting frame
        # 'target' is new frame (which might be relative to the current one)
        def get_whether_this_frame_match_frame_expression(currentFrameString,target)
            return get_boolean("getWhetherThisFrameMatchFrameExpression", [currentFrameString,target,])
        end


        # Determine whether currentWindowString plus target identify the window containing this running code.
        # 
        # This is useful in proxy injection mode, where this code runs in every
        # browser frame and window, and sometimes the selenium server needs to identify
        # the "current" window.  In this case, when the test calls selectWindow, this
        # routine is called for each window to figure out which one has been selected.
        # The selected window will return true, while all others will return false.
        # 
        #
        # 'currentWindowString' is starting window
        # 'target' is new window (which might be relative to the current one, e.g., "_parent")
        def get_whether_this_window_match_window_expression(currentWindowString,target)
            return get_boolean("getWhetherThisWindowMatchWindowExpression", [currentWindowString,target,])
        end


        # Waits for a popup window to appear and load up.
        #
        # 'windowID' is the JavaScript window ID of the window that will appear
        # 'timeout' is a timeout in milliseconds, after which the action will return with an error
        def wait_for_pop_up(windowID,timeout)
            do_command("waitForPopUp", [windowID,timeout,])
        end


        # By default, Selenium's overridden window.confirm() function will
        # return true, as if the user had manually clicked OK.  After running
        # this command, the next call to confirm() will return false, as if
        # the user had clicked Cancel.
        #
        def choose_cancel_on_next_confirmation()
            do_command("chooseCancelOnNextConfirmation", [])
        end


        # Instructs Selenium to return the specified answer string in response to
        # the next JavaScript prompt [window.prompt()].
        #
        # 'answer' is the answer to give in response to the prompt pop-up
        def answer_on_next_prompt(answer)
            do_command("answerOnNextPrompt", [answer,])
        end


        # Simulates the user clicking the "back" button on their browser.
        #
        def go_back()
            do_command("goBack", [])
        end


        # Simulates the user clicking the "Refresh" button on their browser.
        #
        def refresh()
            do_command("refresh", [])
        end


        # Simulates the user clicking the "close" button in the titlebar of a popup
        # window or tab.
        #
        def close()
            do_command("close", [])
        end


        # Has an alert occurred?
        # 
        # 
        # This function never throws an exception
        # 
        # 
        #
        def is_alert_present()
            return get_boolean("isAlertPresent", [])
        end


        # Has a prompt occurred?
        # 
        # 
        # This function never throws an exception
        # 
        # 
        #
        def is_prompt_present()
            return get_boolean("isPromptPresent", [])
        end


        # Has confirm() been called?
        # 
        # 
        # This function never throws an exception
        # 
        # 
        #
        def is_confirmation_present()
            return get_boolean("isConfirmationPresent", [])
        end


        # Retrieves the message of a JavaScript alert generated during the previous action, or fail if there were no alerts.
        # 
        # Getting an alert has the same effect as manually clicking OK. If an
        # alert is generated but you do not get/verify it, the next Selenium action
        # will fail.
        # NOTE: under Selenium, JavaScript alerts will NOT pop up a visible alert
        # dialog.
        # NOTE: Selenium does NOT support JavaScript alerts that are generated in a
        # page's onload() event handler. In this case a visible dialog WILL be
        # generated and Selenium will hang until someone manually clicks OK.
        # 
        #
        def get_alert()
            return get_string("getAlert", [])
        end


        # Retrieves the message of a JavaScript confirmation dialog generated during
        # the previous action.
        # 
        # 
        # By default, the confirm function will return true, having the same effect
        # as manually clicking OK. This can be changed by prior execution of the
        # chooseCancelOnNextConfirmation command. If an confirmation is generated
        # but you do not get/verify it, the next Selenium action will fail.
        # 
        # 
        # NOTE: under Selenium, JavaScript confirmations will NOT pop up a visible
        # dialog.
        # 
        # 
        # NOTE: Selenium does NOT support JavaScript confirmations that are
        # generated in a page's onload() event handler. In this case a visible
        # dialog WILL be generated and Selenium will hang until you manually click
        # OK.
        # 
        # 
        #
        def get_confirmation()
            return get_string("getConfirmation", [])
        end


        # Retrieves the message of a JavaScript question prompt dialog generated during
        # the previous action.
        # 
        # Successful handling of the prompt requires prior execution of the
        # answerOnNextPrompt command. If a prompt is generated but you
        # do not get/verify it, the next Selenium action will fail.
        # NOTE: under Selenium, JavaScript prompts will NOT pop up a visible
        # dialog.
        # NOTE: Selenium does NOT support JavaScript prompts that are generated in a
        # page's onload() event handler. In this case a visible dialog WILL be
        # generated and Selenium will hang until someone manually clicks OK.
        # 
        #
        def get_prompt()
            return get_string("getPrompt", [])
        end


        # Gets the absolute URL of the current page.
        #
        def get_location()
            return get_string("getLocation", [])
        end


        # Gets the title of the current page.
        #
        def get_title()
            return get_string("getTitle", [])
        end


        # Gets the entire text of the page.
        #
        def get_body_text()
            return get_string("getBodyText", [])
        end


        # Gets the (whitespace-trimmed) value of an input field (or anything else with a value parameter).
        # For checkbox/radio elements, the value will be "on" or "off" depending on
        # whether the element is checked or not.
        #
        # 'locator' is an element locator
        def get_value(locator)
            return get_string("getValue", [locator,])
        end


        # Gets the text of an element. This works for any element that contains
        # text. This command uses either the textContent (Mozilla-like browsers) or
        # the innerText (IE-like browsers) of the element, which is the rendered
        # text shown to the user.
        #
        # 'locator' is an element locator
        def get_text(locator)
            return get_string("getText", [locator,])
        end


        # Gets the result of evaluating the specified JavaScript snippet.  The snippet may
        # have multiple lines, but only the result of the last line will be returned.
        # 
        # Note that, by default, the snippet will run in the context of the "selenium"
        # object itself, so <tt>this</tt> will refer to the Selenium object, and <tt>window</tt> will
        # refer to the top-level runner test window, not the window of your application.
        # If you need a reference to the window of your application, you can refer
        # to <tt>this.browserbot.getCurrentWindow()</tt> and if you need to use
        # a locator to refer to a single element in your application page, you can
        # use <tt>this.page().findElement("foo")</tt> where "foo" is your locator.
        # 
        #
        # 'script' is the JavaScript snippet to run
        def get_eval(script)
            return get_string("getEval", [script,])
        end


        # Gets whether a toggle-button (checkbox/radio) is checked.  Fails if the specified element doesn't exist or isn't a toggle-button.
        #
        # 'locator' is an element locator pointing to a checkbox or radio button
        def is_checked(locator)
            return get_boolean("isChecked", [locator,])
        end


        # Gets the text from a cell of a table. The cellAddress syntax
        # tableLocator.row.column, where row and column start at 0.
        #
        # 'tableCellAddress' is a cell address, e.g. "foo.1.4"
        def get_table(tableCellAddress)
            return get_string("getTable", [tableCellAddress,])
        end


        # Gets all option labels (visible text) for selected options in the specified select or multi-select element.
        #
        # 'selectLocator' is an element locator identifying a drop-down menu
        def get_selected_labels(selectLocator)
            return get_string_array("getSelectedLabels", [selectLocator,])
        end


        # Gets option label (visible text) for selected option in the specified select element.
        #
        # 'selectLocator' is an element locator identifying a drop-down menu
        def get_selected_label(selectLocator)
            return get_string("getSelectedLabel", [selectLocator,])
        end


        # Gets all option values (value attributes) for selected options in the specified select or multi-select element.
        #
        # 'selectLocator' is an element locator identifying a drop-down menu
        def get_selected_values(selectLocator)
            return get_string_array("getSelectedValues", [selectLocator,])
        end


        # Gets option value (value attribute) for selected option in the specified select element.
        #
        # 'selectLocator' is an element locator identifying a drop-down menu
        def get_selected_value(selectLocator)
            return get_string("getSelectedValue", [selectLocator,])
        end


        # Gets all option indexes (option number, starting at 0) for selected options in the specified select or multi-select element.
        #
        # 'selectLocator' is an element locator identifying a drop-down menu
        def get_selected_indexes(selectLocator)
            return get_string_array("getSelectedIndexes", [selectLocator,])
        end


        # Gets option index (option number, starting at 0) for selected option in the specified select element.
        #
        # 'selectLocator' is an element locator identifying a drop-down menu
        def get_selected_index(selectLocator)
            return get_string("getSelectedIndex", [selectLocator,])
        end


        # Gets all option element IDs for selected options in the specified select or multi-select element.
        #
        # 'selectLocator' is an element locator identifying a drop-down menu
        def get_selected_ids(selectLocator)
            return get_string_array("getSelectedIds", [selectLocator,])
        end


        # Gets option element ID for selected option in the specified select element.
        #
        # 'selectLocator' is an element locator identifying a drop-down menu
        def get_selected_id(selectLocator)
            return get_string("getSelectedId", [selectLocator,])
        end


        # Determines whether some option in a drop-down menu is selected.
        #
        # 'selectLocator' is an element locator identifying a drop-down menu
        def is_something_selected(selectLocator)
            return get_boolean("isSomethingSelected", [selectLocator,])
        end


        # Gets all option labels in the specified select drop-down.
        #
        # 'selectLocator' is an element locator identifying a drop-down menu
        def get_select_options(selectLocator)
            return get_string_array("getSelectOptions", [selectLocator,])
        end


        # Gets the value of an element attribute.
        #
        # 'attributeLocator' is an element locator followed by an
        def get_attribute(attributeLocator)
            return get_string("getAttribute", [attributeLocator,])
        end


        # Verifies that the specified text pattern appears somewhere on the rendered page shown to the user.
        #
        # 'pattern' is a pattern to match with the text of the page
        def is_text_present(pattern)
            return get_boolean("isTextPresent", [pattern,])
        end


        # Verifies that the specified element is somewhere on the page.
        #
        # 'locator' is an element locator
        def is_element_present(locator)
            return get_boolean("isElementPresent", [locator,])
        end


        # Determines if the specified element is visible. An
        # element can be rendered invisible by setting the CSS "visibility"
        # property to "hidden", or the "display" property to "none", either for the
        # element itself or one if its ancestors.  This method will fail if
        # the element is not present.
        #
        # 'locator' is an element locator
        def is_visible(locator)
            return get_boolean("isVisible", [locator,])
        end


        # Determines whether the specified input element is editable, ie hasn't been disabled.
        # This method will fail if the specified element isn't an input element.
        #
        # 'locator' is an element locator
        def is_editable(locator)
            return get_boolean("isEditable", [locator,])
        end


        # Returns the IDs of all buttons on the page.
        # 
        # If a given button has no ID, it will appear as "" in this array.
        # 
        #
        def get_all_buttons()
            return get_string_array("getAllButtons", [])
        end


        # Returns the IDs of all links on the page.
        # 
        # If a given link has no ID, it will appear as "" in this array.
        # 
        #
        def get_all_links()
            return get_string_array("getAllLinks", [])
        end


        # Returns the IDs of all input fields on the page.
        # 
        # If a given field has no ID, it will appear as "" in this array.
        # 
        #
        def get_all_fields()
            return get_string_array("getAllFields", [])
        end


        # Returns every instance of some attribute from all known windows.
        #
        # 'attributeName' is name of an attribute on the windows
        def get_attribute_from_all_windows(attributeName)
            return get_string_array("getAttributeFromAllWindows", [attributeName,])
        end


        # deprecated - use dragAndDrop instead
        #
        # 'locator' is an element locator
        # 'movementsString' is offset in pixels from the current location to which the element should be moved, e.g., "+70,-300"
        def dragdrop(locator,movementsString)
            do_command("dragdrop", [locator,movementsString,])
        end


        # Drags an element a certain distance and then drops it
        #
        # 'locator' is an element locator
        # 'movementsString' is offset in pixels from the current location to which the element should be moved, e.g., "+70,-300"
        def drag_and_drop(locator,movementsString)
            do_command("dragAndDrop", [locator,movementsString,])
        end


        # Drags an element and drops it on another element
        #
        # 'locatorOfObjectToBeDragged' is an element to be dragged
        # 'locatorOfDragDestinationObject' is an element whose location (i.e., whose top left corner) will be the point where locatorOfObjectToBeDragged  is dropped
        def drag_and_drop_to_object(locatorOfObjectToBeDragged,locatorOfDragDestinationObject)
            do_command("dragAndDropToObject", [locatorOfObjectToBeDragged,locatorOfDragDestinationObject,])
        end


        # Gives focus to a window
        #
        # 'windowName' is name of the window to be given focus
        def window_focus(windowName)
            do_command("windowFocus", [windowName,])
        end


        # Resize window to take up the entire screen
        #
        # 'windowName' is name of the window to be enlarged
        def window_maximize(windowName)
            do_command("windowMaximize", [windowName,])
        end


        # Returns the IDs of all windows that the browser knows about.
        #
        def get_all_window_ids()
            return get_string_array("getAllWindowIds", [])
        end


        # Returns the names of all windows that the browser knows about.
        #
        def get_all_window_names()
            return get_string_array("getAllWindowNames", [])
        end


        # Returns the titles of all windows that the browser knows about.
        #
        def get_all_window_titles()
            return get_string_array("getAllWindowTitles", [])
        end


        # Returns the entire HTML source between the opening and
        # closing "html" tags.
        #
        def get_html_source()
            return get_string("getHtmlSource", [])
        end


        # Moves the text cursor to the specified position in the given input element or textarea.
        # This method will fail if the specified element isn't an input element or textarea.
        #
        # 'locator' is an element locator pointing to an input element or textarea
        # 'position' is the numerical position of the cursor in the field; position should be 0 to move the position to the beginning of the field.  You can also set the cursor to -1 to move it to the end of the field.
        def set_cursor_position(locator,position)
            do_command("setCursorPosition", [locator,position,])
        end


        # Get the relative index of an element to its parent (starting from 0). The comment node and empty text node
        # will be ignored.
        #
        # 'locator' is an element locator pointing to an element
        def get_element_index(locator)
            return get_number("getElementIndex", [locator,])
        end


        # Check if these two elements have same parent and are ordered. Two same elements will
        # not be considered ordered.
        #
        # 'locator1' is an element locator pointing to the first element
        # 'locator2' is an element locator pointing to the second element
        def is_ordered(locator1,locator2)
            return get_boolean("isOrdered", [locator1,locator2,])
        end


        # Retrieves the horizontal position of an element
        #
        # 'locator' is an element locator pointing to an element OR an element itself
        def get_element_position_left(locator)
            return get_number("getElementPositionLeft", [locator,])
        end


        # Retrieves the vertical position of an element
        #
        # 'locator' is an element locator pointing to an element OR an element itself
        def get_element_position_top(locator)
            return get_number("getElementPositionTop", [locator,])
        end


        # Retrieves the width of an element
        #
        # 'locator' is an element locator pointing to an element
        def get_element_width(locator)
            return get_number("getElementWidth", [locator,])
        end


        # Retrieves the height of an element
        #
        # 'locator' is an element locator pointing to an element
        def get_element_height(locator)
            return get_number("getElementHeight", [locator,])
        end


        # Retrieves the text cursor position in the given input element or textarea; beware, this may not work perfectly on all browsers.
        # 
        # Specifically, if the cursor/selection has been cleared by JavaScript, this command will tend to
        # return the position of the last location of the cursor, even though the cursor is now gone from the page.  This is filed as SEL-243.
        # 
        # This method will fail if the specified element isn't an input element or textarea, or there is no cursor in the element.
        #
        # 'locator' is an element locator pointing to an input element or textarea
        def get_cursor_position(locator)
            return get_number("getCursorPosition", [locator,])
        end


        # Writes a message to the status bar and adds a note to the browser-side
        # log.
        # 
        # If logLevelThreshold is specified, set the threshold for logging
        # to that level (debug, info, warn, error).
        # (Note that the browser-side logs will <em>not</em> be sent back to the
        # server, and are invisible to the Client Driver.)
        # 
        #
        # 'context' is the message to be sent to the browser
        # 'logLevelThreshold' is one of "debug", "info", "warn", "error", sets the threshold for browser-side logging
        def set_context(context,logLevelThreshold)
            do_command("setContext", [context,logLevelThreshold,])
        end


        # Returns the specified expression.
        # 
        # This is useful because of JavaScript preprocessing.
        # It is used to generate commands like assertExpression and waitForExpression.
        # 
        #
        # 'expression' is the value to return
        def get_expression(expression)
            return get_string("getExpression", [expression,])
        end


        # Runs the specified JavaScript snippet repeatedly until it evaluates to "true".
        # The snippet may have multiple lines, but only the result of the last line
        # will be considered.
        # 
        # Note that, by default, the snippet will be run in the runner's test window, not in the window
        # of your application.  To get the window of your application, you can use
        # the JavaScript snippet <tt>selenium.browserbot.getCurrentWindow()</tt>, and then
        # run your JavaScript in there
        # 
        #
        # 'script' is the JavaScript snippet to run
        # 'timeout' is a timeout in milliseconds, after which this command will return with an error
        def wait_for_condition(script,timeout)
            do_command("waitForCondition", [script,timeout,])
        end


        # Specifies the amount of time that Selenium will wait for actions to complete.
        # 
        # Actions that require waiting include "open" and the "waitFor*" actions.
        # 
        # The default timeout is 30 seconds.
        #
        # 'timeout' is a timeout in milliseconds, after which the action will return with an error
        def set_timeout(timeout)
            do_command("setTimeout", [timeout,])
        end


        # Waits for a new page to load.
        # 
        # You can use this command instead of the "AndWait" suffixes, "clickAndWait", "selectAndWait", "typeAndWait" etc.
        # (which are only available in the JS API).
        # Selenium constantly keeps track of new pages loading, and sets a "newPageLoaded"
        # flag when it first notices a page load.  Running any other Selenium command after
        # turns the flag to false.  Hence, if you want to wait for a page to load, you must
        # wait immediately after a Selenium command that caused a page-load.
        # 
        #
        # 'timeout' is a timeout in milliseconds, after which this command will return with an error
        def wait_for_page_to_load(timeout)
            do_command("waitForPageToLoad", [timeout,])
        end


        # Return all cookies of the current page under test.
        #
        def get_cookie()
            return get_string("getCookie", [])
        end


        # Create a new cookie whose path and domain are same with those of current page
        # under test, unless you specified a path for this cookie explicitly.
        #
        # 'nameValuePair' is name and value of the cookie in a format "name=value"
        # 'optionsString' is options for the cookie. Currently supported options include 'path' and 'max_age'.      the optionsString's format is "path=/path/, max_age=60". The order of options are irrelevant, the unit      of the value of 'max_age' is second.
        def create_cookie(nameValuePair,optionsString)
            do_command("createCookie", [nameValuePair,optionsString,])
        end


        # Delete a named cookie with specified path.
        #
        # 'name' is the name of the cookie to be deleted
        # 'path' is the path property of the cookie to be deleted
        def delete_cookie(name,path)
            do_command("deleteCookie", [name,path,])
        end


    end

    SeleneseInterpreter = SeleniumDriver # for backward compatibility

end

class SeleniumCommandError < RuntimeError 
end

# Defines a mixin module that you can use to write Selenium tests
# without typing "@selenium." in front of every command.  Every
# call to a missing method will be automatically sent to the @selenium
# object.
module SeleniumHelper
    
    # Overrides standard "open" method with @selenium.open
    def open(addr)
      @selenium.open(addr)
    end
    
    # Overrides standard "type" method with @selenium.type
    def type(inputLocator, value)
      @selenium.type(inputLocator, value)
    end
    
    # Overrides standard "select" method with @selenium.select
    def select(inputLocator, optionLocator)
      @selenium.select(inputLocator, optionLocator)
    end

    # Passes all calls to missing methods to @selenium
    def method_missing(method_name, *args)
        if args.empty?
            @selenium.send(method_name)
        else
            @selenium.send(method_name, *args)
        end
    end
end
