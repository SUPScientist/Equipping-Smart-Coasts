As with [Directions-for-Google-Sheets-PtI.md](./Directions-for-Google-Sheets-PtI.md), I've copied these directions from the web, this time from http://railsrescue.com/blog/2015-05-28-step-by-step-setup-to-send-form-data-to-google-sheets/. As previously described, there are two critical sections from that resource which must be followed:

**"The sheet"**  
**"The script"**

## The Sheet
Navigate to drive.google.com and click on NEW > Google Sheets to create a new Sheet. Give it a name, perhaps “Form Google Sheets”. Put the following names into the first row of the first five columns:

Timestamp  name  email phone message

NB: I haven't tested what happens if `email`, `phone`, and `message` are excluded. I have a sensor deployed in the field relying on this operation and will not ship new code until I have the sensor back in the lab.


## The Script
Click on Tools > Script Editor…, which should open a new window and a dialog called 'Google Apps Script’. Click on Create script for > Custom Functions in Sheets. This will create one script called 'Code.gs’ containing functions such as SAY_HELLO.

Click on 'Untitled Project’ at the top and give this project a name: 'Form Script’.

Highlight all of this script (we are going to replace it) and paste in the following:

```
//  1. Enter sheet name where data is to be written below
        var SHEET_NAME = "Sheet1";

//  2. Run > setup
//
//  3. Publish > Deploy as web app
//    - enter Project Version name and click 'Save New Version'
//    - set security level and enable service (most likely execute as 'me' and access 'anyone, even anonymously)
//
//  4. Copy the 'Current web app URL' and post this in your form/script action
//
//  5. Insert column names on your destination sheet matching the parameter names of the data you are passing in (exactly matching case)

var SCRIPT_PROP = PropertiesService.getScriptProperties(); // new property service

// If you don't want to expose either GET or POST methods you can comment out the appropriate function
function doGet(e){
  return handleResponse(e);
}

function doPost(e){
  return handleResponse(e);
}

function handleResponse(e) {
  // shortly after my original solution Google announced the LockService[1]
  // this prevents concurrent access overwritting data
  // [1] http://googleappsdeveloper.blogspot.co.uk/2011/10/concurrency-and-google-apps-script.html
  // we want a public lock, one that locks for all invocations
  var lock = LockService.getPublicLock();
  lock.waitLock(30000);  // wait 30 seconds before conceding defeat.

  try {
    // next set where we write the data - you could write to multiple/alternate destinations
    var doc = SpreadsheetApp.openById(SCRIPT_PROP.getProperty("key"));
    var sheet = doc.getSheetByName(SHEET_NAME);

    // we'll assume header is in row 1 but you can override with header_row in GET/POST data
    var headRow = e.parameter.header_row || 1;
    var headers = sheet.getRange(1, 1, 1, sheet.getLastColumn()).getValues()[0];
    var nextRow = sheet.getLastRow()+1; // get next row
    var row = [];
    // loop through the header columns
    for (i in headers){
      if (headers[i] == "Timestamp"){ // special case if you include a 'Timestamp' column
        row.push(new Date());
      } else { // else use header name to get data
        row.push(e.parameter[headers[i]]);
      }
    }
    // more efficient to set values as [][] array than individually
    sheet.getRange(nextRow, 1, 1, row.length).setValues([row]);
    // return json success results
    return ContentService
          .createTextOutput(JSON.stringify({"result":"success", "row": nextRow}))
          .setMimeType(ContentService.MimeType.JSON);
  } catch(e){
    // if error return this
    return ContentService
          .createTextOutput(JSON.stringify({"result":"error", "error": e}))
          .setMimeType(ContentService.MimeType.JSON);
  } finally { //release lock
    lock.releaseLock();
  }
}

function setup() {
    var doc = SpreadsheetApp.getActiveSpreadsheet();
    SCRIPT_PROP.setProperty("key", doc.getId());
}
```

Click on the Save icon. Set the dropdown in the nav bar to 'setup’ and click on the right-pointing triangle to its left to run this function. It should show 'Running function setup’ and then put up a dialog 'Authorization Required’. Click on Continue. In the next dialog 'Request for permission - Formscript would like to’ click on Accept.

In the menus click on File > Manage Versions… We must save a version of the script for it to be called. In the box labeled 'Describe what has changed’ type 'Initial version’ and click on 'Save New Version’, then on 'OK’.

Back to the menus: click on Resources > Current Project’s triggers. In this dialog click on 'No triggers set up. Click here to add one now’. In the dropdowns select 'doPost’, 'From spreadsheet’, and 'On form submit’, then click on 'Save’.

Back to the menus: click on Publish > Deploy as web app… For 'Who has access to the app:’ select 'Anyone, even anonymous’. Leave 'Execute the app as:’ set to 'Me’ and Project Version to '1’. Click the 'Deploy’ button.

A dialog should appear announcing 'This project is now deployed as a web app’. Copy the Current web app URL from the dialog; it should look something like:

https://script.google.com/macros/s/abcdefghijklmnopqrstuvwxyz/exec
Click OK.
