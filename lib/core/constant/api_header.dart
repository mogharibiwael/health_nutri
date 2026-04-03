
getHeader(token) {
 return  {
    "Accept": "application/json",
    "Content-Type": "application/json",
    "User-Agent": "PostmanRuntime/7.43.0", // Mimic Postman for better compatibility
    if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
  };
}

getHeaderForFile(token) {
  return {
    "Accept": "application/octet-stream,*/*",
    "User-Agent": "PostmanRuntime/7.43.0",
    if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
  };
}