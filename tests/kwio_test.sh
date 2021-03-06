#!/bin/bash

. ./tests/utils --source-only
. ./src/kwio.sh --source-only

declare -A configurations
sound_file="$PWD/tests/.kwio_test_aux/sound.file"
visual_file="$PWD/tests/.kwio_test_aux/visual.file"

function suite
{
  suite_addTest "testAlertOptions"
  suite_addTest "testAlertDefaultOptions"
  suite_addTest "testAlertCommandPrinting"
}

function setUp
{
  mkdir -p tests/.kwio_test_aux
  configurations["sound_alert_command"]="touch $sound_file"
  configurations["visual_alert_command"]="touch $visual_file"
}

function tearDown
{
  rm -rf tests/.kwio_test_aux
}


function testAlertOptions
{
  configurations["alert"]="n"

  rm -f "$sound_file" "$visual_file"
  alert_completion "" "--alert=vs"
  [[ -f "$sound_file" && -f "$visual_file" ]]
  assertTrue "Alert's vs option didn't work." $?

  rm -f "$sound_file" "$visual_file"
  alert_completion "" "--alert=sv"
  [[ -f "$sound_file" && -f "$visual_file" ]]
  assertTrue "Alert's sv option didn't work." $?

  rm -f "$sound_file" "$visual_file"
  alert_completion "" "--alert=s"
  [[ -f "$sound_file" && ! -f "$visual_file" ]]
  assertTrue "Alert's s option didn't work." $?

  rm -f "$sound_file" "$visual_file"
  alert_completion "" "--alert=v"
  [[ ! -f "$sound_file" && -f "$visual_file" ]]
  assertTrue "Alert's v option didn't work." $?

  rm -f "$sound_file" "$visual_file"
  alert_completion "" "--alert=n"
  [[ ! -f "$sound_file" && ! -f "$visual_file" ]]
  assertTrue "Alert's n option didn't work." $?

  true
}

function testAlertDefaultOptions
{
  mkdir -p tests/.kwio_test_aux

  rm -f "$sound_file" "$visual_file"
  configurations["alert"]="vs"
  alert_completion "" ""
  [[ -f "$sound_file" && -f "$visual_file" ]]
  assertTrue "Alert's vs option didn't work." $?

  rm -f "$sound_file" "$visual_file"
  configurations["alert"]="sv"
  alert_completion "" ""
  [[ -f "$sound_file" && -f "$visual_file" ]]
  assertTrue "Alert's sv option didn't work." $?

  rm -f "$sound_file" "$visual_file"
  configurations["alert"]="s"
  alert_completion "" ""
  [[ -f "$sound_file" && ! -f "$visual_file" ]]
  assertTrue "Alert's s option didn't work." $?

  rm -f "$sound_file" "$visual_file"
  configurations["alert"]="v"
  alert_completion "" ""
  [[ ! -f "$sound_file" && -f "$visual_file" ]]
  assertTrue "Alert's v option didn't work." $?

  rm -f "$sound_file" "$visual_file"
  configurations["alert"]="n"
  alert_completion "" ""
  [[ ! -f "$sound_file" && ! -f "$visual_file" ]]
  assertTrue "Alert's n option didn't work." $?

  true
}

function testAlertCommandPrinting
{
  local expected="TESTING COMMAND"
  configurations["visual_alert_command"]="echo \$COMMAND"
  ret="$(alert_completion "$expected" "--alert=v")"
  assertEquals "Variable $v should exist." "$ret" "$expected"
  true
}

invoke_shunit
