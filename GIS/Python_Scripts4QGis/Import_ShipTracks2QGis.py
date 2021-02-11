import os
import glob

fpath = "D:/IOW%20Marine%20Geophysik%20Dropbox/Mischa%20Sch%C3%B6nke/4_Projekte/MGF/EMB238_2020_Data_Analysis/MBES/QPS_Export_GEO04/Tracklog_Control/"
#fpath = "D:/IOW Marine Geophysik Dropbox/Mischa Schönke/4_Projekte/MGF/EMB238_2020_Data_Analysis/MBES/QPS_Export_GEO04/Tracklog_Control/"

groupName = "ShipTrack_Control"

root = QgsProject.instance().layerTreeRoot()
txtGroup = root.addGroup(groupName)
FileDefinition = "?type=csv&useHeader=no&detectTypes=yes&xField=field_2&yField=field_3&crs=EPSG:32632&spatialIndex=no&subsetIndex=no&watchFile=no&geomType=point"


# Find each .csv file and load them as point vector layers for fname in
for fname in glob.glob("*.txt"):  
   uri = "file:///" + fpath + fname + FileDefinition
   filename = QgsVectorLayer(uri, fname[:-4], 'delimitedtext')
   QgsProject.instance().addMapLayer(filename,False)
   txtGroup.insertChildNode(1,QgsLayerTreeLayer(filename))