# ClaimSure API Integration Documentation

## Overview
This directory contains API service classes for integrating with the ClaimSure backend server running on `http://10.186.50.129:8000/`.

## API Service (`api_service.dart`)

### Base Configuration
- **Base URL**: `http://10.186.50.129:8000`
- **Timeout**: 30 seconds
- **Content Type**: `application/json`

### Available Methods

#### `createUser()`
Creates a new user account on the server.

**Endpoint**: `POST /create-user`

**Parameters**:
```dart
{
  required String username,    // User's chosen username
  required String phoneNo,     // Phone number for 2FA
  required String password,    // User's password
}
```

**Request Body**:
```json
{
  "username": "john_doe",
  "phone_no": "9876543210", 
  "pwd": "securePassword123"
}
```

**Response Format**:
```dart
// Success Response
{
  'success': true,
  'data': {...},              // Server response data
  'message': 'User created successfully'
}

// Error Response
Exception('Server Error (400): Username already exists')
```

**Usage Example**:
```dart
try {
  final result = await ApiService.createUser(
    username: 'john_doe',
    phoneNo: '9876543210',
    password: 'securePassword123'
  );
  
  if (result['success']) {
    print('✅ User created: ${result['message']}');
    // Navigate to next screen
  }
} catch (e) {
  print('❌ Error: $e');
  // Show error message to user
}
```

#### `checkServerHealth()`
Validates if the API server is reachable.

**Endpoint**: `GET /health`

**Returns**: `bool` - true if server is accessible

**Usage Example**:
```dart
bool isOnline = await ApiService.checkServerHealth();
if (!isOnline) {
  showDialog(context, 'Server is currently unavailable');
}
```

## Error Handling

The API service handles different types of errors:

### Network Errors
- **Cause**: No internet connection, server unreachable
- **Message**: "Network Error: Please check your internet connection"

### Server Errors  
- **Cause**: HTTP status codes 400-599
- **Message**: "Server Error (404): Endpoint not found"

### Data Format Errors
- **Cause**: Invalid JSON response from server
- **Message**: "Data Format Error: Invalid response from server"

### Timeout Errors
- **Cause**: Request takes longer than 30 seconds
- **Message**: "Network Error: Request timeout"

## Integration in Signup Screen

The signup screen (`signup.dart`) integrates with the API service:

1. **Form Validation**: Validates all required fields
2. **Loading State**: Shows spinner during API call
3. **API Call**: Calls `ApiService.createUser()`
4. **Success Handling**: Shows success message and navigates
5. **Error Handling**: Shows appropriate error messages

### Key Features:
- **Username Generation**: Extracts username from full name
- **Loading Indicator**: Prevents multiple submissions
- **Error Messages**: User-friendly error descriptions
- **Success Feedback**: Confirmation before navigation

## Security Considerations

1. **HTTPS**: Consider upgrading to HTTPS in production
2. **API Keys**: Add authentication headers if required
3. **Input Validation**: Server-side validation is essential
4. **Error Logging**: Remove debug logs in production
5. **Timeout Handling**: Prevents hanging requests

## Testing

To test the API integration:

1. **Server Status**: Ensure `http://10.186.50.129:8000/` is running
2. **Endpoint Test**: Verify `/create-user` accepts POST requests
3. **Network Test**: Test with different network conditions
4. **Error Test**: Test with invalid data to verify error handling

## Future Enhancements

1. **Authentication**: Add JWT token support
2. **Retry Logic**: Implement automatic retry for failed requests
3. **Caching**: Cache responses for better performance
4. **Offline Support**: Queue requests when offline
5. **Analytics**: Track API usage and errors
