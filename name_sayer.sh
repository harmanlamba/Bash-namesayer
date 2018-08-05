#!/bin/bash
 
function dispMainMenu(){
    printf "\n=========================================================\n"
    printf "Welcome to NameSayer\n"
    printf "=========================================================\n"
    printf "Please select from one of the following options:\n\n"
    printf "      (l)ist existing creations\n"
    printf "      (p)lay an existing creations\n"
    printf "      (d)elete an existing creations\n"
    printf "      (c)reate a new creation\n"
    printf "      (q)uit authoring tool\n\n"
   
   
 
}
 
 
 
function listExistingCreations(){
    if(cd creations 2>> error_message.txt 1>>stdOut.txt); then
        if [ ! $(ls ./creations | wc -l) -eq 0 ]; then
            counter="1";
            cd creations
            printf "The creations are: \n"
            ls | while read fname; do
                echo "      $counter. ${fname%%.mp4}"
                counter=$((counter+1))
            done
            counter=$(ls | wc -l)
            cd ..
            printf "\nThere are a total of %u creations\n" "$counter"
       else
        printf "There are no creations created yet, or were all deleted\n"
        read -n 1 -r -s -p "Press any key to continue..."
        clear
        mainMenu
       fi
       
    else
        printf "There are no creations created yet, or were all deleted\n"
        read -n 1 -r -s -p "Press any key to continue..."
        clear
        mainMenu
 
    fi
}
 
 
 
 
function playExistingCreation(){
    listExistingCreations
    printf "\nWhich creation would you like to play?\n"
    read -p "Please enter the name of the creation, excluding the file extension:" creationName
    if [ -f ./creations/"$creationName".mp4 ]; then
        ffplay -autoexit ./creations/"$creationName".mp4 2>> error_message.txt 1>>stdOut.txt
    else
        printf "The creation you have typed does not exist, please confirm the spelling\n"
        read -n 1 -r -s -p "Press any key to continue..."
        clear
        mainMenu
    fi
    clear
    mainMenu
 
}
 
 
function deleteExistingCreation(){
    listExistingCreations

    if [ ! $(ls ./creations | wc -l) -eq 0 ]; then

        printf "\nWhich creation would you like to delete?\n"
        read -p "Please enter the name of the creation, excluding the file extension:" deleteName
        printf "\nYou are wanting to delete %s\n" "$deleteName"
        if [ -f ./creations/"$deleteName".mp4 ]; then
            read -r -p "Are you sure? [Y/n]:" response
            case "$response" in
            [yY][eE][sS]|[yY])
            rm -r ./creations/"$deleteName".mp4 1>>stdOut.txt 2>>error_message.txt
            printf "The creation %s has been deleted\n" "$deleteName"
            listExistingCreations
            read -n 1 -r -s -p "Press any key to continue..."
            ;;
            *)
            echo Aborting
            read -n 1 -r -s -p "Press any key to continue..."
            ;;
        esac
            clear
            mainMenu
        else
            printf "The creation you have typed does not exist, please confirm the spelling\n"
            printf "!!!Aborting!!!\n"
            read -n 1 -r -s -p "Press any key to continue..."
            clear
            mainMenu
    
        fi

    else 
        printf "There are no creations created yet, or were all deleted\n"
        read -n 1 -r -s -p "Press any key to continue..."
        mainMenu
    fi
}
 
 
function createNewCreation(){
 
   #Making Video
   if [ ! -d ./creations ]; then
     mkdir ./creations  
   fi
 
    creationExist=0 #true
    while [ $creationExist -eq 0 ]; do
        read -p "Please enter the name of the creation, excluding the file extension:" creationName
   
    if [ -f ./creations/"$creationName".mp4 ]; then
        creationExist=0
        printf "\nCreation name already exist, you will be prompted to enter another name\n"
    else
        creationExist=1 #false
        mkdir ./tempCreations 2>> error_message.txt 1>>stdOut.txt
        ffmpeg -f lavfi -i color=c=blue:s=600x600:d=5 -vf "drawtext=fontfile=/usr/share/fonts/truetype/ubuntu/Ubuntu-RI.ttf:fontsize=30: fontcolor=white:x=(w-text_w)/2:y=(h-text_h)/2:text='$creationName'" ./tempCreations/"$creationName".mp4 \
        2>> error_message.txt 1>>stdOut.txt
 
    fi
    done
 
        recordingAudio "$creationName"
 
     rm -r tempCreations
     clear
     mainMenu
 
 
}
 
 
function confirmRecording(){
    creationName=$1
    printf "\n"
    read -r -p "Would you like to (l)isten, (r)edo, or (k)eep the recording:" response
    case "$response" in
        [kK]|[kK][eE][pP][pP])
            ffmpeg -i ./tempCreations/"$creationName".mp4 -i ./tempCreations/"$creationName".mkv \
            -c:v copy -c:a aac -strict experimental ./creations/"$creationName".mp4 \
            2>> error_message.txt 1>>stdOut.txt
            read -n 1 -r -s -p "Press any key to continue..."
        ;;
        [rR]|[rR][eE][dD][oO])
        rm -r ./tempCreations/"$creationName".mkv 2>> error_message.txt 1>>stdOut.txt
        recordingAudio "$creationName"
        ;;
        [lL]|[lL][iI][sS][tT][eE][nN])
        ffplay -autoexit ./tempCreations/"$creationName".mkv 2>>error_message.txt 1>>stdOut.txt
        read -n 1 -r -s -p "Press any key to continue..."
        confirmRecording "$creationName"
        ;;
        *)
        confirmRecording "$1"
        ;;

    esac
}
 
function recordingAudio(){
    creationName=$1
    printf "\nWe need to now record audio for the creation, speak loud and clear into the mic for 5 seconds\n"
    read -n 1 -r -s -p "Press any key to start recording..."
    printf "\nRecording"
    ffmpeg -f alsa -ac 2 -i hw:0 -t 5  ./tempCreations/"$creationName".mkv 2>>error_message.txt 1>>stdOut.txt
    confirmRecording "$creationName"
}
 
 
 
 
 
function quitAuthoringTool(){
    echo "Quitting NameSayer"
    exit 0
}
 
function mainMenu(){
    clear
    dispMainMenu
    read -r -p "Enter a selection [l/p/d/c/q]:" selection
    case "$selection" in
    [lL])
        listExistingCreations
        read -n 1 -r -s -p "Press any key to continue..."
        clear
        mainMenu
    ;;
    [pP])
        playExistingCreation
    ;;
    [dD])
        deleteExistingCreation
    ;;
    [cC])
        createNewCreation
    ;;
    [Qq]|[Qq][Uu][Ii][Tt])
        quitAuthoringTool
    ;;
    *)
        printf "\nPlease enter a valid selection:\n"
        read -n 1 -r -s -p "Press any key to continue..."
        mainMenu
    esac
 
 
}
 
 
mainMenu
