# File Locations
$rootFolder = "D:\MovieNight"

$movieFolder = "D:\MovieNight\Movies"
$movieListPath = "D:\MovieNight\Movies\MovieList.txt"

$clipsFolder = "D:\MovieNight\Clips"
$introClipListPath = "D:\MovieNight\Clips\IntroClips.txt"
$intermissionClipListPath = "D:\MovieNight\Clips\IntermissionClips.txt"
$endClipListPath = "D:\MovieNight\Clips\EndClips.txt"



$MovieTimeOffSet = 300 # in seconds, amount of time CurlRun2 runs before the end of the movie
$Intermission = 600 # in seconds, amount of time given after the end of the movie

# Uncomment the following line if you wish to auto shut down your system at the end of the movie. intermission time will play after movie before shutting down
# $EndOfNightShutDown = $true



# Lighting Controls, uncomment if you wish to use them
#$CurlRun1 = { curl.exe --max-time 2 -d GET http://192.168.144.13:8123/api/webhook/BackyardMovieNightStart } # Pre-movie lighting
#$CurlRun2 = { curl.exe --max-time 2 -d GET http://192.168.144.13:8123/api/webhook/BackyardMovieNightLightsOn } # Post-movie lighting
#$CurlRun3Option1 = { curl.exe --max-time 2 -d GET http://192.168.144.13:8123/api/webhook/BackyardMovieNightLightsOff } # All movies finished lighting
#$CurlRun3Option2 = { curl.exe --max-time 2 -d GET http://192.168.144.13:8123/api/webhook/BackyardMovieNightDoubleFeatureStart } # Intermission lighting
