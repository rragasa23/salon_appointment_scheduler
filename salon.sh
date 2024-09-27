#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {

  # print any arguments
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # welcome
  echo -e "\nWelcome to My Salon, how can I help you?\n"

  # Get available services
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id,name FROM services")
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  # ask for a service
  read SERVICE_ID_SELECTED

  # if service to choose is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
	then
		# send to main menu
		MAIN_MENU "That is not a valid service number."
	else
    SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    #if not available
    if [[ -z $SERVICE_ID ]]
    then
      # send back to main menu
      MAIN_MENU "That service is not available."
    else
      #ask for phone number
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      #get name
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

      #if name not in system
      if [[ -z $CUSTOMER_NAME ]]
      then

        #ask for name
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
      fi

      #ask for appointment time
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
      CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed -E 's/ *$|^ *//g')
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
      SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed -E 's/ *$|^ *//g')
      echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
      read SERVICE_TIME

      #create the appointment
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

      echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
      #MAIN_MENU
    fi
  fi

}

MAIN_MENU
