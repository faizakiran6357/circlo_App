
import 'package:googleapis_auth/auth_io.dart';

class GetServerKey{
  Future<String> getServerKeyToken() async {
    final scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];

    final client = await clientViaServiceAccount(ServiceAccountCredentials.fromJson(
   {
  "type": "service_account",
  "project_id": "circlo-app",
  "private_key_id": "2da50c4946a4c05dc09ede158f06fa4b2c9c26f9",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQC0QpvXPp+i7dT+\ncMsnBJfzYIoE4ktVJ6LA3Phos6lR1AzgtAxiKBMWJuDvoHeJd+gMU1GjjWgeZoha\n5zYEWDFOqSQFPJtUYOhr+IUZXfK2nScErP4aMzldnBMzt9JYP55qFsjpsw7zkCEr\n+vieQunYcnQ02+UJDEfh+IwjVOXT4rtxJTCKZhshVWEtnnSHxVEMSvaD8WmAmxwe\nccKdooOHLCzjbMBL7z3ybUY7oorKa0yBnZ4uEEVaEsBqsFnMlv8beobFNBcFtimg\nUryol+MCJ3CB63YVLrc7mFPEsZjpX+ty91kSAoThs6yj9X1jDOO2dBfkTQ8msBbV\n1aYgJjI5AgMBAAECggEADOWrIsZfQ5gCokXNszf36zjgByNtwmT4lxX4S/12wt0K\nItWfATLe0rnrZBm2E8bZenBHqg0HAw3Q+bgLPFpXBMrDQgCpGGtqlbcNRtha8kfi\nL8p0z8kUdKcjFJM1YI0Et5BzxYzDKBgK14u4WBJvisX9nH6TL4eKaReQZ0K+wt8Z\n/Vc4iPdW8Bng5bEFnc15lzfB6BvRsMHzP2hNzaScwc52nG9hBgVkizkKMpN1WIYb\nckS41uA/NlWpyBGWKS3iHoaE8nK0XDGftrKD1tSCDcHMZN8qUhql2rekJpKkcvT5\nRt/LtcSSZ2KUaIQXrUMk6ojKBTBztoKkB4kR2NF9UQKBgQD4BxLsRq+Cr8+xWtqb\nVfCl0BaCggZUcfWTnfVdjEx1jINvH2gWNagD2CoU0JDOTFJIn9TZ3h16OaIyknUT\nRrZMYhrms6Y3ksvcRDnHfrjg8TjvbHbrLArtbLvngHMW0F5k73BwYw08mVLPIsbZ\nN8AUSo3uS8/T7r78xW++wA6irQKBgQC6DebsoMBflcitD/iuLsS0lnzJLzF3oDgD\nfKJT0X2rWywvcJimFGY04eM+wrbknxp9qjJLdYFymFbHS0yt1MQuzFaJW8TcgZo3\nES3yoiB5j+AHMHMc1KsGR8OIzvvKdYXaYZ52Yi5TXje2FMg1e+SvqguVwFGBYFLM\nhz9yi9wLPQKBgHjwWhXD0cjTmV5NgtLDcPgpIxC3/gYnGyvDleTriEy5G02P7t0F\nhMt7F+nWWQV+yZCH/u3NFGqIt8IZD+U6UaGlJKDhcGcguS7KRbI05Ekq1ixIoyPA\n8gMbRfR3+aZiK+Tjq9vhMI8f4/UEbBl2yb4bLGHJrakVfSMb0oUceQZxAoGAe8kS\nEe9l7nKGYHZW2vSs1QWmomfuvotvmQpMKf4gYWi4fhuoxB6gXaDIg5IjAvrEMkWR\nTtkwNeEbI1969dCwcf5ruNnAoYDs7KRWcK7jcl2CDOZ0QANSgkwu0Q/9QBdu5fu6\n5UKvVbJC2Lb8+XCjlyhIquqYj75ZeFCnqvtYfHUCgYAWYTDzF50Zp4BpPAZeS2KY\niEHxrfov4yW7/hJjkDcFtfLfYqAYBnDK6XlQXqZ3PuMLin5cbe2Zi01KbCWf2pM3\naMZBp/L7KO4MfjCLlldIGIGL/iNeLK6YYFr9YpOpRHsstjQen3dEL/eoqiZftuJo\nyM9YSMvrX4ze9Noaaj13Zw==\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-fbsvc@circlo-app.iam.gserviceaccount.com",
  "client_id": "114585490664897272574",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40circlo-app.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
), 
scopes);

final accessToken = client.credentials.accessToken.data;
    print("Access Token: $accessToken"); // <--- see in console
    return accessToken;
  }
}