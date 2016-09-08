# Strava Progress Tracker for [Übersicht](http://tracesof.net/uebersicht/)

<img src="https://github.com/Pe8er/Strava.widget/blob/master/screenshot.jpg" width="516" height="320">

## [Download](https://github.com/Pe8er/Strava.widget/raw/master/Strava.widget.zip)

This widget grabs your weekly and yearly biking stats from [Strava](https://www.strava.com/) and displays them in a somewhat visual manner.

<img src="https://github.com/Pe8er/Strava.widget/blob/master/instructions.jpg" width="420" height="300">

## How to Use

1. Unzip and copy `Strava.widget` folder to `~/Library/Application Support/Übersicht/Widgets` folder.
1. Open `Strava/widget/index.coffee` in a text editor.
2. Edit values in lines 7-13 to set your preferences:

```
options =
  # Easily enable or disable the widget.
  widgetEnable  :         true
  # Your Strava user ID. It's at the end of your profile page URL.
  myid          :         "XXX"
  # Your Strava authorization token. Get one here: https://www.strava.com/settings/api. If you keep using mine, you will see my stats. Those aren't very impressive :)
  token         :         "XXXX"
  # Distance units: KM for kilometers or M for miles.
  units         :         "KM"
  # Your yearly biking goal in kilometers.
  yearlygoal    :         "4000"
  # Vertical distance from top left corner of the screen. Set it to 0 if you're using this widget within Sidebar meta-widget. No need to put it inside Sidebar folder!
  top           :         "0"
  # Horizontal distance from top left corner of the screen. Set it to 0 if you're using this widget within Sidebar meta-widget. No need to put it inside Sidebar folder!
  left          :         "0"
```

If you don't add your **user ID** and **authorization token**, the widget will not show up at all.

It supports flex positioning, easy background blur and tons of probably very poorly written code.

[See my other widgets](https://github.com/Pe8er/Ubersicht-Widgets)
