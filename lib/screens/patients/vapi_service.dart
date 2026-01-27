import 'dart:async';
import 'dart:convert';
import 'package:vapi/vapi.dart';

class VapiService {
  static final VapiService _instance = VapiService._internal();
  factory VapiService() => _instance;
  VapiService._internal();

  VapiClient? _client;
  VapiCall? _currentCall;

  final StreamController<Map<String, dynamic>> _formDataController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get formDataStream => _formDataController.stream;

  bool _initialized = false;

  Future<void> initialize(String publicKey) async {
    if (_initialized) return;
    await VapiClient.platformInitialized.future;
    _client = VapiClient(publicKey.trim());
    _initialized = true;
    print('✅ Vapi Client Initialized');
  }

  Future<void> startCall(String assistantId) async {
    if (_client == null) {
      throw Exception("VapiService not initialized. Call initialize() first.");
    }

    print('🚀 Starting call with assistant: $assistantId');
    _currentCall = await _client!.start(assistantId: assistantId.trim());
    print('✅ Call object created');

    _currentCall!.onEvent.listen((event) {
      print('');
      print('🔔 ========== VAPI EVENT ==========');
      print('📍 Event Label: ${event.label}');
      print('📦 Event Value: ${event.value}');
      print('==================================');
      print('');

      switch (event.label) {
        case "call-start":
          print("✅ Call started successfully");
          break;

        case "call-end":
          print("📞 Call ended");
          break;

        case "speech-start":
          print("🗣️ User started speaking");
          break;

        case "speech-end":
          print("🗣️ User finished speaking");
          break;

        case "transcript":
          _handleTranscript(event.value);
          break;

        case "message":
          _handleMessage(event.value);
          break;

        case "tool-calls":
          print("🔧 TOOL-CALLS EVENT DETECTED!");
          _handleToolCalls(event.value);
          break;

        case "function-call":
          print("🔧 FUNCTION-CALL EVENT DETECTED!");
          _handleFunctionCall(event.value);
          break;

        default:
          print("ℹ️ Unhandled event: ${event.label}");
      }
    }, onError: (error) {
      print('❌ Event stream error: $error');
    });

    print('✅ Event listener attached');
  }

  void _handleTranscript(dynamic value) {
    if (value == null) return;
    
    try {
      print('📝 Transcript received: $value');
      
      if (value is Map) {
        final text = value['text'] ?? value['transcript'];
        final role = value['role'];
        print('📝 Role: $role, Text: $text');
      } else if (value is String) {
        print('📝 Transcript text: $value');
      }
    } catch (e) {
      print('❌ Error handling transcript: $e');
    }
  }

  void _handleMessage(dynamic value) {
    if (value == null) return;

    try {
      print('📨 Processing message event...');
      
      Map<String, dynamic> messageData;
      if (value is Map) {
        messageData = Map<String, dynamic>.from(value);
      } else if (value is String) {
        messageData = jsonDecode(value);
      } else {
        print('⚠️ Unknown message format: ${value.runtimeType}');
        return;
      }

      print('📨 Message Data Keys: ${messageData.keys.toList()}');
      
      final messageType = messageData['type'];
      final role = messageData['role'];
      
      print('📨 Message Type: $messageType');
      print('📨 Message Role: $role');

      if (messageType == 'tool-calls') {
        print('🔧 Message type is tool-calls');
        final toolCalls = messageData['toolCalls'] ?? 
                         messageData['tool_calls'] ?? 
                         messageData['toolCallList'] ?? 
                         [];
        
        if (toolCalls is List && toolCalls.isNotEmpty) {
          print('🔧 Found ${toolCalls.length} tool call(s) in message');
          _processToolCalls(toolCalls);
        }
      }
    } catch (e, stackTrace) {
      print('❌ Error handling message: $e');
      print('Stack trace: $stackTrace');
    }
  }

  void _handleToolCalls(dynamic value) {
    if (value == null) return;

    try {
      print('🔧 Processing tool-calls event...');
      print('🔧 Value type: ${value.runtimeType}');
      print('🔧 Value: $value');
      
      List<dynamic> toolCalls = [];
      
      if (value is List) {
        toolCalls = value;
      } else if (value is Map) {
        final map = Map<String, dynamic>.from(value);
        toolCalls = map['toolCalls'] ?? 
                   map['tool_calls'] ?? 
                   map['toolCallList'] ?? 
                   [];
      } else if (value is String) {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          toolCalls = decoded;
        } else if (decoded is Map) {
          final map = Map<String, dynamic>.from(decoded);
          toolCalls = map['toolCalls'] ?? 
                     map['tool_calls'] ?? 
                     map['toolCallList'] ?? 
                     [];
        }
      }

      if (toolCalls.isNotEmpty) {
        print('🔧 Processing ${toolCalls.length} tool calls');
        _processToolCalls(toolCalls);
      } else {
        print('⚠️ No tool calls found in value');
      }
    } catch (e, stackTrace) {
      print('❌ Error handling tool-calls: $e');
      print('Stack trace: $stackTrace');
    }
  }

  void _handleFunctionCall(dynamic value) {
    if (value == null) return;

    try {
      print('🔧 Processing function call event...');
      
      Map<String, dynamic> functionData;
      if (value is Map) {
        functionData = Map<String, dynamic>.from(value);
      } else if (value is String) {
        functionData = jsonDecode(value);
      } else {
        print('⚠️ Unknown function call format: ${value.runtimeType}');
        return;
      }

      print('🔧 Function Data: $functionData');
      
      final functionName = functionData['name'] ?? 
                          functionData['function']?['name'];
      print('🔧 Function Name: $functionName');

      if (functionName == 'book_appointment') {
        final arguments = functionData['arguments'] ?? 
                         functionData['parameters'] ?? 
                         functionData['function']?['arguments'];
        
        _processArguments(arguments);
      }
    } catch (e, stackTrace) {
      print('❌ Error handling function call: $e');
      print('Stack trace: $stackTrace');
    }
  }

  void _processToolCalls(List toolCalls) {
    print('🔧 ========== PROCESSING TOOL CALLS ==========');
    print('🔧 Number of tool calls: ${toolCalls.length}');
    
    for (var i = 0; i < toolCalls.length; i++) {
      final toolCall = toolCalls[i];
      print('🔧 Tool Call #$i: $toolCall');
      
      if (toolCall is! Map) {
        print('⚠️ Tool call is not a Map, skipping');
        continue;
      }
      
      final toolCallMap = Map<String, dynamic>.from(toolCall);
      final type = toolCallMap['type'];
      final functionData = toolCallMap['function'];
      
      print('🔧 Tool Call Type: $type');
      print('🔧 Function Data: $functionData');

      if (functionData != null && functionData is Map) {
        final functionMap = Map<String, dynamic>.from(functionData);
        final functionName = functionMap['name'];
        
        print('🔧 Function Name: $functionName');

        if (functionName == 'book_appointment') {
          final arguments = functionMap['arguments'];
          print('🔧 Found book_appointment function with arguments: $arguments');
          _processArguments(arguments);
        }
      }
    }
    print('🔧 ========================================');
  }

  void _processArguments(dynamic arguments) {
    print('📦 ========== PROCESSING ARGUMENTS ==========');
    print('📦 Arguments: $arguments');
    print('📦 Arguments Type: ${arguments.runtimeType}');

    try {
      Map<String, dynamic> formData;
      
      if (arguments is Map) {
        formData = Map<String, dynamic>.from(arguments);
      } else if (arguments is String) {
        formData = Map<String, dynamic>.from(jsonDecode(arguments));
      } else {
        print('❌ Unknown arguments type: ${arguments.runtimeType}');
        return;
      }

      print('🎉 ========== EXTRACTED FORM DATA ==========');
      print('appointmentType: ${formData['appointmentType']}');
      print('date: ${formData['date']}');
      print('time: ${formData['time']}');
      print('reason: ${formData['reason']}');
      print('==========================================');
      print('ℹ️  Doctor and Room will be selected manually by user');
      
      final filteredData = {
        'appointmentType': formData['appointmentType'],
        'date': formData['date'],
        'time': formData['time'],
        'reason': formData['reason'],
      };
      
      _formDataController.add(filteredData);
      
      print('✅ Form data sent to stream (without doctor/room)!');
    } catch (e, stackTrace) {
      print('❌ Error processing arguments: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> stopCall() async {
    print('🛑 Stopping call...');
    await _currentCall?.stop();
    _currentCall = null;
    print('✅ Call stopped');
  }

  bool get isMuted => _currentCall?.isMuted ?? false;

  Future<void> toggleMute() async {
    if (_currentCall == null) return;
    _currentCall!.setMuted(!isMuted);
    print('🔇 Mute toggled: ${!isMuted}');
  }

  void dispose() {
    print('🧹 Disposing VapiService...');
    _formDataController.close();
    _currentCall?.dispose();
    _client?.dispose();
  }
}

class AppConfig {
  static const String enAssistantId = "c2938829-8d3e-4db2-ba4f-b5c7b1cb0f06";

  static String getAssistantId() {
    return enAssistantId;
  }
}