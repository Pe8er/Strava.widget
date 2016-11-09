# Strava Progress Tracker for [Übersicht](http://tracesof.net/uebersicht/)

<img src="https://github.com/Pe8er/Strava.widget/blob/master/screenshot.jpg?raw=true" width="516" height="320">

## [Download](https://github.com/Pe8er/Strava.widget/raw/master/Strava.widget.zip)

This widget grabs your weekly and yearly biking stats from [Strava](https://www.strava.com/) and displays them in a somewhat visual manner.

<img src="https://github.com/Pe8er/Strava.widget/blob/master/instructions.jpg?raw=true" width="420" height="300">

## How to Use

1. Unzip and copy `Strava.widget` folder to `~/Library/Application Support/Übersicht/Widgets` folder.
1. Open `Strava/widget/index.coffee` in a text editor.
2. Edit values in lines 7-13 to set your preferences:

```
options =
  # Easily enable or disable the widget.
  widgetEnable    :         true
  # Your Strava user ID. It's at the end of your profile page URL.
  myid            :         "XXXXX"
  # Your Strava authorization token. Get one here - www.strava.com/settings/api.
  token           :         "XXXXXXXXXXXXXXXXXXX"
  # Distance units: KM for kilometers or M for miles.
  units           :         "KM"
  # Your yearly biking goal in kilometers.
  yearlygoal      :         "4000"
  # When do you want to meet your goal? If it's empty, it will set the date to the last day of current year. Use "MM/DD/YY" format.
  deadline      :         ""
  # Stick the widget in the bottom right corner? Set to *true* if you're using it with Sidebar widget, set to *false* if you'd like to give it some breathing room and a drop shadow.
  stickInCorner   :         true
```

If you don't add your **user ID** and **authorization token**, the widget will not show up at all.

It supports flex positioning, easy background blur and tons of probably very poorly written code.

[See my other widgets](https://github.com/Pe8er/Ubersicht-Widgets)
