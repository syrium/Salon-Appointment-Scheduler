#!/bin/bash
# PSQL variable
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# Make Appointment Function
MAKE_APPOINTMNET () {
  if [[ $1 || $2 ]]
  then
    SERVICE_ID_SELECTED=$1
    SERVICE_NAME_SELECTED=$2
  fi
  # Ask phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  echo -e "\n$CUSTOMER_PHONE"
  # Check phone number in customers 
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  
  if [[ -z $CUSTOMER_ID ]]
  then
    # if not found, register
    # ask name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    ADD_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
    if [[ $ADD_CUSTOMER == 'INSERT 0 1' ]]
    then
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      # ask time with service and name
      echo -e "\nWhat time would you like your $SERVICE_NAME_SELECTED, $CUSTOMER_NAME?"
      read SERVICE_TIME

      # add appointment
      ADD_APPOINTMENT=$($PSQL "INSERT INTO appointments(service_id, time, customer_id) VALUES($SERVICE_ID_SELECTED, '$SERVICE_TIME', $CUSTOMER_ID)")
      # confirm appointment
      if [[ $ADD_APPOINTMENT == 'INSERT 0 1' ]]
      then
        echo -e "\nI have put you down for a $SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
      fi
    fi
  else
    # if found, make appointment
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

      # ask time with service and name
      echo -e "\nWhat time would you like your $SERVICE_NAME_SELECTED, $CUSTOMER_NAME?"
      read SERVICE_TIME

      # add appointment
      ADD_APPOINTMENT=$($PSQL "INSERT INTO appointments(service_id, time, customer_id) VALUES($SERVICE_ID_SELECTED, '$SERVICE_TIME', $CUSTOMER_ID)")
      # confirm appointment
      if [[ $ADD_APPOINTMENT == 'INSERT 0 1' ]]
      then
        echo -e "\nI have put you down for a $SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
      fi
  fi
}

# Main Menu
MAIN_MENU () {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  # Show a list of services
  echo -e "$($PSQL "SELECT * FROM services ORDER BY service_id")" | sed 's/^ *//; s/ |/)/' 
  # read service choice
  read SERVICE_ID_SELECTED
  # Check service ID 
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # Invalid input
    MAIN_MENU "Please input number only."
  else
    SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_NAME_SELECTED ]]
    then
      # if input not in service list
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      MAKE_APPOINTMNET $SERVICE_ID_SELECTED $SERVICE_NAME_SELECTED
    fi
  fi
}

# display title
echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?\n"
MAIN_MENU
