function str = ReadUrl(url)
     is = java.net.URL([], url, sun.net.www.protocol.https.Handler).openConnection().getInputStream(); 
     br = java.io.BufferedReader(java.io.InputStreamReader(is));
     str = char(br.readLine());
 end