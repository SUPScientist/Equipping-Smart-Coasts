NB: I've copied the following instructions from https://www.hackster.io/gusgonnet/pushing-data-to-google-docs-02f9c4
which refers to other online posts. For the sake of maintaining access to the instructions, I've copied them below and made minor grammatical edits; all credit for the following content belongs to the authors of those articles and their sources.

# Story
In this article I will explain how your hardware can push data into a Google spreadsheet.

## Push Versus Poll
In the poll mechanism, as described in my previous article, the Google spreadsheet runs a script that sends a request to fetch data from our hardware at a regular interval.

You can use the poll mechanism when your hardware is online all the time, for instance to capture sensor data that changes slowly over time (example: the temperature of your pool).

In the push mechanism, described in the current article, your hardware sends a request with data to a Google server running a script that will, in turn, store that data received in a Google spreadsheet.

The pull mechanism is ideal when your hardware might be sleeping from time to time (hence not reachable), to capture a specific event (example: your garage door is opening) or to store a log of what your hardware is doing.

Note: I used a Particle Photon in this project, but I think the mechanism can be helpful with other hardware in general, like Arduinos and Raspberry Pies.

## Set Up the Google Docs Side
Please follow the instructions on [Directions-for-Google-Sheets-PtII.md](./Directions-for-Google-Sheets-PtII.md). In particular, follow ONLY these two sections:

**"The sheet"**  
**"The script"**

## Set Up your Hardware to Push Data - Particle's Case
In the case you are using a Particle, you will need two things:

configure a webhook
code a publish command in your firmware to trigger that webhook with the wanted information
How this works:

STEP 1: the webhook

Create a particle webhook with the following information:

event name: googleDocs

full url: what you get from google docs (example: https://script.google.com/macros/s/123123123123123-456456/exec)

method: POST

form (one way to look at it): `key=name value={{my-name}}`

form in JSON (another way to look at it):

```
{
  "name": "{{my-name}}"
}
headers: "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"

include defaults: no

Enforce SSL: yes
```

Here's a screenshot of the webhook:

STEP 2: the firmware

Then in your firmware, add a line like this one:  
`String tempMessage = "Your garage door is opening";
Particle.publish("googleDocs", "{\"my-name\":\"" + tempMessage + "\"}", 60, PRIVATE);`  
Note: I'm using a dynamic custom field feature on webhooks that I learned in this discussion. You can read a bit more in this tutorial (search for mustache since the link seems not to work perfectly).

STEP 3: verify the console logs

Every time your hardware triggers the webhook you should see something like this in your Particle console logs:

Results
Here you can see how my hardware is filling up my Google spreadsheet:

Note: There are limits on how many times per day the Google API can be hit by your hardware. I'm pretty sure you would be able to pay Google for increasing your traffic quota, but I haven't looked into it.
