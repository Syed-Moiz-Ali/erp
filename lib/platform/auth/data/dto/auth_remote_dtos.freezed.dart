// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_remote_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LoginRequestDto {

 String get loginId; String get password;
/// Create a copy of LoginRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginRequestDtoCopyWith<LoginRequestDto> get copyWith => _$LoginRequestDtoCopyWithImpl<LoginRequestDto>(this as LoginRequestDto, _$identity);

  /// Serializes this LoginRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginRequestDto&&(identical(other.loginId, loginId) || other.loginId == loginId)&&(identical(other.password, password) || other.password == password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,loginId,password);

@override
String toString() {
  return 'LoginRequestDto(loginId: $loginId, password: $password)';
}


}

/// @nodoc
abstract mixin class $LoginRequestDtoCopyWith<$Res>  {
  factory $LoginRequestDtoCopyWith(LoginRequestDto value, $Res Function(LoginRequestDto) _then) = _$LoginRequestDtoCopyWithImpl;
@useResult
$Res call({
 String loginId, String password
});




}
/// @nodoc
class _$LoginRequestDtoCopyWithImpl<$Res>
    implements $LoginRequestDtoCopyWith<$Res> {
  _$LoginRequestDtoCopyWithImpl(this._self, this._then);

  final LoginRequestDto _self;
  final $Res Function(LoginRequestDto) _then;

/// Create a copy of LoginRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loginId = null,Object? password = null,}) {
  return _then(_self.copyWith(
loginId: null == loginId ? _self.loginId : loginId // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LoginRequestDto].
extension LoginRequestDtoPatterns on LoginRequestDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginRequestDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _LoginRequestDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _LoginRequestDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String loginId,  String password)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginRequestDto() when $default != null:
return $default(_that.loginId,_that.password);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String loginId,  String password)  $default,) {final _that = this;
switch (_that) {
case _LoginRequestDto():
return $default(_that.loginId,_that.password);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String loginId,  String password)?  $default,) {final _that = this;
switch (_that) {
case _LoginRequestDto() when $default != null:
return $default(_that.loginId,_that.password);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoginRequestDto implements LoginRequestDto {
  const _LoginRequestDto({required this.loginId, required this.password});
  factory _LoginRequestDto.fromJson(Map<String, dynamic> json) => _$LoginRequestDtoFromJson(json);

@override final  String loginId;
@override final  String password;

/// Create a copy of LoginRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginRequestDtoCopyWith<_LoginRequestDto> get copyWith => __$LoginRequestDtoCopyWithImpl<_LoginRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoginRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginRequestDto&&(identical(other.loginId, loginId) || other.loginId == loginId)&&(identical(other.password, password) || other.password == password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,loginId,password);

@override
String toString() {
  return 'LoginRequestDto(loginId: $loginId, password: $password)';
}


}

/// @nodoc
abstract mixin class _$LoginRequestDtoCopyWith<$Res> implements $LoginRequestDtoCopyWith<$Res> {
  factory _$LoginRequestDtoCopyWith(_LoginRequestDto value, $Res Function(_LoginRequestDto) _then) = __$LoginRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 String loginId, String password
});




}
/// @nodoc
class __$LoginRequestDtoCopyWithImpl<$Res>
    implements _$LoginRequestDtoCopyWith<$Res> {
  __$LoginRequestDtoCopyWithImpl(this._self, this._then);

  final _LoginRequestDto _self;
  final $Res Function(_LoginRequestDto) _then;

/// Create a copy of LoginRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loginId = null,Object? password = null,}) {
  return _then(_LoginRequestDto(
loginId: null == loginId ? _self.loginId : loginId // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$RefreshRequestDto {

 String get refreshToken;
/// Create a copy of RefreshRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RefreshRequestDtoCopyWith<RefreshRequestDto> get copyWith => _$RefreshRequestDtoCopyWithImpl<RefreshRequestDto>(this as RefreshRequestDto, _$identity);

  /// Serializes this RefreshRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RefreshRequestDto&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,refreshToken);

@override
String toString() {
  return 'RefreshRequestDto(refreshToken: $refreshToken)';
}


}

/// @nodoc
abstract mixin class $RefreshRequestDtoCopyWith<$Res>  {
  factory $RefreshRequestDtoCopyWith(RefreshRequestDto value, $Res Function(RefreshRequestDto) _then) = _$RefreshRequestDtoCopyWithImpl;
@useResult
$Res call({
 String refreshToken
});




}
/// @nodoc
class _$RefreshRequestDtoCopyWithImpl<$Res>
    implements $RefreshRequestDtoCopyWith<$Res> {
  _$RefreshRequestDtoCopyWithImpl(this._self, this._then);

  final RefreshRequestDto _self;
  final $Res Function(RefreshRequestDto) _then;

/// Create a copy of RefreshRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? refreshToken = null,}) {
  return _then(_self.copyWith(
refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RefreshRequestDto].
extension RefreshRequestDtoPatterns on RefreshRequestDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RefreshRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RefreshRequestDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RefreshRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _RefreshRequestDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RefreshRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _RefreshRequestDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String refreshToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RefreshRequestDto() when $default != null:
return $default(_that.refreshToken);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String refreshToken)  $default,) {final _that = this;
switch (_that) {
case _RefreshRequestDto():
return $default(_that.refreshToken);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String refreshToken)?  $default,) {final _that = this;
switch (_that) {
case _RefreshRequestDto() when $default != null:
return $default(_that.refreshToken);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RefreshRequestDto implements RefreshRequestDto {
  const _RefreshRequestDto({required this.refreshToken});
  factory _RefreshRequestDto.fromJson(Map<String, dynamic> json) => _$RefreshRequestDtoFromJson(json);

@override final  String refreshToken;

/// Create a copy of RefreshRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RefreshRequestDtoCopyWith<_RefreshRequestDto> get copyWith => __$RefreshRequestDtoCopyWithImpl<_RefreshRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RefreshRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RefreshRequestDto&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,refreshToken);

@override
String toString() {
  return 'RefreshRequestDto(refreshToken: $refreshToken)';
}


}

/// @nodoc
abstract mixin class _$RefreshRequestDtoCopyWith<$Res> implements $RefreshRequestDtoCopyWith<$Res> {
  factory _$RefreshRequestDtoCopyWith(_RefreshRequestDto value, $Res Function(_RefreshRequestDto) _then) = __$RefreshRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 String refreshToken
});




}
/// @nodoc
class __$RefreshRequestDtoCopyWithImpl<$Res>
    implements _$RefreshRequestDtoCopyWith<$Res> {
  __$RefreshRequestDtoCopyWithImpl(this._self, this._then);

  final _RefreshRequestDto _self;
  final $Res Function(_RefreshRequestDto) _then;

/// Create a copy of RefreshRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? refreshToken = null,}) {
  return _then(_RefreshRequestDto(
refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$LogoutRequestDto {

 String get refreshToken;
/// Create a copy of LogoutRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LogoutRequestDtoCopyWith<LogoutRequestDto> get copyWith => _$LogoutRequestDtoCopyWithImpl<LogoutRequestDto>(this as LogoutRequestDto, _$identity);

  /// Serializes this LogoutRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LogoutRequestDto&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,refreshToken);

@override
String toString() {
  return 'LogoutRequestDto(refreshToken: $refreshToken)';
}


}

/// @nodoc
abstract mixin class $LogoutRequestDtoCopyWith<$Res>  {
  factory $LogoutRequestDtoCopyWith(LogoutRequestDto value, $Res Function(LogoutRequestDto) _then) = _$LogoutRequestDtoCopyWithImpl;
@useResult
$Res call({
 String refreshToken
});




}
/// @nodoc
class _$LogoutRequestDtoCopyWithImpl<$Res>
    implements $LogoutRequestDtoCopyWith<$Res> {
  _$LogoutRequestDtoCopyWithImpl(this._self, this._then);

  final LogoutRequestDto _self;
  final $Res Function(LogoutRequestDto) _then;

/// Create a copy of LogoutRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? refreshToken = null,}) {
  return _then(_self.copyWith(
refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LogoutRequestDto].
extension LogoutRequestDtoPatterns on LogoutRequestDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LogoutRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LogoutRequestDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LogoutRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _LogoutRequestDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LogoutRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _LogoutRequestDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String refreshToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LogoutRequestDto() when $default != null:
return $default(_that.refreshToken);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String refreshToken)  $default,) {final _that = this;
switch (_that) {
case _LogoutRequestDto():
return $default(_that.refreshToken);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String refreshToken)?  $default,) {final _that = this;
switch (_that) {
case _LogoutRequestDto() when $default != null:
return $default(_that.refreshToken);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LogoutRequestDto implements LogoutRequestDto {
  const _LogoutRequestDto({required this.refreshToken});
  factory _LogoutRequestDto.fromJson(Map<String, dynamic> json) => _$LogoutRequestDtoFromJson(json);

@override final  String refreshToken;

/// Create a copy of LogoutRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LogoutRequestDtoCopyWith<_LogoutRequestDto> get copyWith => __$LogoutRequestDtoCopyWithImpl<_LogoutRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LogoutRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LogoutRequestDto&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,refreshToken);

@override
String toString() {
  return 'LogoutRequestDto(refreshToken: $refreshToken)';
}


}

/// @nodoc
abstract mixin class _$LogoutRequestDtoCopyWith<$Res> implements $LogoutRequestDtoCopyWith<$Res> {
  factory _$LogoutRequestDtoCopyWith(_LogoutRequestDto value, $Res Function(_LogoutRequestDto) _then) = __$LogoutRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 String refreshToken
});




}
/// @nodoc
class __$LogoutRequestDtoCopyWithImpl<$Res>
    implements _$LogoutRequestDtoCopyWith<$Res> {
  __$LogoutRequestDtoCopyWithImpl(this._self, this._then);

  final _LogoutRequestDto _self;
  final $Res Function(_LogoutRequestDto) _then;

/// Create a copy of LogoutRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? refreshToken = null,}) {
  return _then(_LogoutRequestDto(
refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$AuthBranchDto {

 int get orgId; String get branchName;
/// Create a copy of AuthBranchDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthBranchDtoCopyWith<AuthBranchDto> get copyWith => _$AuthBranchDtoCopyWithImpl<AuthBranchDto>(this as AuthBranchDto, _$identity);

  /// Serializes this AuthBranchDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthBranchDto&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.branchName, branchName) || other.branchName == branchName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,orgId,branchName);

@override
String toString() {
  return 'AuthBranchDto(orgId: $orgId, branchName: $branchName)';
}


}

/// @nodoc
abstract mixin class $AuthBranchDtoCopyWith<$Res>  {
  factory $AuthBranchDtoCopyWith(AuthBranchDto value, $Res Function(AuthBranchDto) _then) = _$AuthBranchDtoCopyWithImpl;
@useResult
$Res call({
 int orgId, String branchName
});




}
/// @nodoc
class _$AuthBranchDtoCopyWithImpl<$Res>
    implements $AuthBranchDtoCopyWith<$Res> {
  _$AuthBranchDtoCopyWithImpl(this._self, this._then);

  final AuthBranchDto _self;
  final $Res Function(AuthBranchDto) _then;

/// Create a copy of AuthBranchDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? orgId = null,Object? branchName = null,}) {
  return _then(_self.copyWith(
orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as int,branchName: null == branchName ? _self.branchName : branchName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthBranchDto].
extension AuthBranchDtoPatterns on AuthBranchDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthBranchDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthBranchDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthBranchDto value)  $default,){
final _that = this;
switch (_that) {
case _AuthBranchDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthBranchDto value)?  $default,){
final _that = this;
switch (_that) {
case _AuthBranchDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int orgId,  String branchName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthBranchDto() when $default != null:
return $default(_that.orgId,_that.branchName);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int orgId,  String branchName)  $default,) {final _that = this;
switch (_that) {
case _AuthBranchDto():
return $default(_that.orgId,_that.branchName);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int orgId,  String branchName)?  $default,) {final _that = this;
switch (_that) {
case _AuthBranchDto() when $default != null:
return $default(_that.orgId,_that.branchName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthBranchDto implements AuthBranchDto {
  const _AuthBranchDto({required this.orgId, required this.branchName});
  factory _AuthBranchDto.fromJson(Map<String, dynamic> json) => _$AuthBranchDtoFromJson(json);

@override final  int orgId;
@override final  String branchName;

/// Create a copy of AuthBranchDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthBranchDtoCopyWith<_AuthBranchDto> get copyWith => __$AuthBranchDtoCopyWithImpl<_AuthBranchDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthBranchDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthBranchDto&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.branchName, branchName) || other.branchName == branchName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,orgId,branchName);

@override
String toString() {
  return 'AuthBranchDto(orgId: $orgId, branchName: $branchName)';
}


}

/// @nodoc
abstract mixin class _$AuthBranchDtoCopyWith<$Res> implements $AuthBranchDtoCopyWith<$Res> {
  factory _$AuthBranchDtoCopyWith(_AuthBranchDto value, $Res Function(_AuthBranchDto) _then) = __$AuthBranchDtoCopyWithImpl;
@override @useResult
$Res call({
 int orgId, String branchName
});




}
/// @nodoc
class __$AuthBranchDtoCopyWithImpl<$Res>
    implements _$AuthBranchDtoCopyWith<$Res> {
  __$AuthBranchDtoCopyWithImpl(this._self, this._then);

  final _AuthBranchDto _self;
  final $Res Function(_AuthBranchDto) _then;

/// Create a copy of AuthBranchDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? orgId = null,Object? branchName = null,}) {
  return _then(_AuthBranchDto(
orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as int,branchName: null == branchName ? _self.branchName : branchName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$AuthUserDto {

 int get userId; String get loginId; String get name; String get userType; int? get empId; int get orgId; String? get branchName; String? get timeZone; int? get orgCount; bool get transactionAccess; bool get reportAccess; List<AuthBranchDto> get branches;
/// Create a copy of AuthUserDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthUserDtoCopyWith<AuthUserDto> get copyWith => _$AuthUserDtoCopyWithImpl<AuthUserDto>(this as AuthUserDto, _$identity);

  /// Serializes this AuthUserDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthUserDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.loginId, loginId) || other.loginId == loginId)&&(identical(other.name, name) || other.name == name)&&(identical(other.userType, userType) || other.userType == userType)&&(identical(other.empId, empId) || other.empId == empId)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.branchName, branchName) || other.branchName == branchName)&&(identical(other.timeZone, timeZone) || other.timeZone == timeZone)&&(identical(other.orgCount, orgCount) || other.orgCount == orgCount)&&(identical(other.transactionAccess, transactionAccess) || other.transactionAccess == transactionAccess)&&(identical(other.reportAccess, reportAccess) || other.reportAccess == reportAccess)&&const DeepCollectionEquality().equals(other.branches, branches));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,loginId,name,userType,empId,orgId,branchName,timeZone,orgCount,transactionAccess,reportAccess,const DeepCollectionEquality().hash(branches));

@override
String toString() {
  return 'AuthUserDto(userId: $userId, loginId: $loginId, name: $name, userType: $userType, empId: $empId, orgId: $orgId, branchName: $branchName, timeZone: $timeZone, orgCount: $orgCount, transactionAccess: $transactionAccess, reportAccess: $reportAccess, branches: $branches)';
}


}

/// @nodoc
abstract mixin class $AuthUserDtoCopyWith<$Res>  {
  factory $AuthUserDtoCopyWith(AuthUserDto value, $Res Function(AuthUserDto) _then) = _$AuthUserDtoCopyWithImpl;
@useResult
$Res call({
 int userId, String loginId, String name, String userType, int? empId, int orgId, String? branchName, String? timeZone, int? orgCount, bool transactionAccess, bool reportAccess, List<AuthBranchDto> branches
});




}
/// @nodoc
class _$AuthUserDtoCopyWithImpl<$Res>
    implements $AuthUserDtoCopyWith<$Res> {
  _$AuthUserDtoCopyWithImpl(this._self, this._then);

  final AuthUserDto _self;
  final $Res Function(AuthUserDto) _then;

/// Create a copy of AuthUserDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? loginId = null,Object? name = null,Object? userType = null,Object? empId = freezed,Object? orgId = null,Object? branchName = freezed,Object? timeZone = freezed,Object? orgCount = freezed,Object? transactionAccess = null,Object? reportAccess = null,Object? branches = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,loginId: null == loginId ? _self.loginId : loginId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,userType: null == userType ? _self.userType : userType // ignore: cast_nullable_to_non_nullable
as String,empId: freezed == empId ? _self.empId : empId // ignore: cast_nullable_to_non_nullable
as int?,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as int,branchName: freezed == branchName ? _self.branchName : branchName // ignore: cast_nullable_to_non_nullable
as String?,timeZone: freezed == timeZone ? _self.timeZone : timeZone // ignore: cast_nullable_to_non_nullable
as String?,orgCount: freezed == orgCount ? _self.orgCount : orgCount // ignore: cast_nullable_to_non_nullable
as int?,transactionAccess: null == transactionAccess ? _self.transactionAccess : transactionAccess // ignore: cast_nullable_to_non_nullable
as bool,reportAccess: null == reportAccess ? _self.reportAccess : reportAccess // ignore: cast_nullable_to_non_nullable
as bool,branches: null == branches ? _self.branches : branches // ignore: cast_nullable_to_non_nullable
as List<AuthBranchDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthUserDto].
extension AuthUserDtoPatterns on AuthUserDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthUserDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthUserDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthUserDto value)  $default,){
final _that = this;
switch (_that) {
case _AuthUserDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthUserDto value)?  $default,){
final _that = this;
switch (_that) {
case _AuthUserDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int userId,  String loginId,  String name,  String userType,  int? empId,  int orgId,  String? branchName,  String? timeZone,  int? orgCount,  bool transactionAccess,  bool reportAccess,  List<AuthBranchDto> branches)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthUserDto() when $default != null:
return $default(_that.userId,_that.loginId,_that.name,_that.userType,_that.empId,_that.orgId,_that.branchName,_that.timeZone,_that.orgCount,_that.transactionAccess,_that.reportAccess,_that.branches);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int userId,  String loginId,  String name,  String userType,  int? empId,  int orgId,  String? branchName,  String? timeZone,  int? orgCount,  bool transactionAccess,  bool reportAccess,  List<AuthBranchDto> branches)  $default,) {final _that = this;
switch (_that) {
case _AuthUserDto():
return $default(_that.userId,_that.loginId,_that.name,_that.userType,_that.empId,_that.orgId,_that.branchName,_that.timeZone,_that.orgCount,_that.transactionAccess,_that.reportAccess,_that.branches);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int userId,  String loginId,  String name,  String userType,  int? empId,  int orgId,  String? branchName,  String? timeZone,  int? orgCount,  bool transactionAccess,  bool reportAccess,  List<AuthBranchDto> branches)?  $default,) {final _that = this;
switch (_that) {
case _AuthUserDto() when $default != null:
return $default(_that.userId,_that.loginId,_that.name,_that.userType,_that.empId,_that.orgId,_that.branchName,_that.timeZone,_that.orgCount,_that.transactionAccess,_that.reportAccess,_that.branches);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthUserDto implements AuthUserDto {
  const _AuthUserDto({required this.userId, required this.loginId, required this.name, required this.userType, this.empId, required this.orgId, this.branchName, this.timeZone, this.orgCount, this.transactionAccess = false, this.reportAccess = false, final  List<AuthBranchDto> branches = const <AuthBranchDto>[]}): _branches = branches;
  factory _AuthUserDto.fromJson(Map<String, dynamic> json) => _$AuthUserDtoFromJson(json);

@override final  int userId;
@override final  String loginId;
@override final  String name;
@override final  String userType;
@override final  int? empId;
@override final  int orgId;
@override final  String? branchName;
@override final  String? timeZone;
@override final  int? orgCount;
@override@JsonKey() final  bool transactionAccess;
@override@JsonKey() final  bool reportAccess;
 final  List<AuthBranchDto> _branches;
@override@JsonKey() List<AuthBranchDto> get branches {
  if (_branches is EqualUnmodifiableListView) return _branches;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_branches);
}


/// Create a copy of AuthUserDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthUserDtoCopyWith<_AuthUserDto> get copyWith => __$AuthUserDtoCopyWithImpl<_AuthUserDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthUserDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthUserDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.loginId, loginId) || other.loginId == loginId)&&(identical(other.name, name) || other.name == name)&&(identical(other.userType, userType) || other.userType == userType)&&(identical(other.empId, empId) || other.empId == empId)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.branchName, branchName) || other.branchName == branchName)&&(identical(other.timeZone, timeZone) || other.timeZone == timeZone)&&(identical(other.orgCount, orgCount) || other.orgCount == orgCount)&&(identical(other.transactionAccess, transactionAccess) || other.transactionAccess == transactionAccess)&&(identical(other.reportAccess, reportAccess) || other.reportAccess == reportAccess)&&const DeepCollectionEquality().equals(other._branches, _branches));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,loginId,name,userType,empId,orgId,branchName,timeZone,orgCount,transactionAccess,reportAccess,const DeepCollectionEquality().hash(_branches));

@override
String toString() {
  return 'AuthUserDto(userId: $userId, loginId: $loginId, name: $name, userType: $userType, empId: $empId, orgId: $orgId, branchName: $branchName, timeZone: $timeZone, orgCount: $orgCount, transactionAccess: $transactionAccess, reportAccess: $reportAccess, branches: $branches)';
}


}

/// @nodoc
abstract mixin class _$AuthUserDtoCopyWith<$Res> implements $AuthUserDtoCopyWith<$Res> {
  factory _$AuthUserDtoCopyWith(_AuthUserDto value, $Res Function(_AuthUserDto) _then) = __$AuthUserDtoCopyWithImpl;
@override @useResult
$Res call({
 int userId, String loginId, String name, String userType, int? empId, int orgId, String? branchName, String? timeZone, int? orgCount, bool transactionAccess, bool reportAccess, List<AuthBranchDto> branches
});




}
/// @nodoc
class __$AuthUserDtoCopyWithImpl<$Res>
    implements _$AuthUserDtoCopyWith<$Res> {
  __$AuthUserDtoCopyWithImpl(this._self, this._then);

  final _AuthUserDto _self;
  final $Res Function(_AuthUserDto) _then;

/// Create a copy of AuthUserDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? loginId = null,Object? name = null,Object? userType = null,Object? empId = freezed,Object? orgId = null,Object? branchName = freezed,Object? timeZone = freezed,Object? orgCount = freezed,Object? transactionAccess = null,Object? reportAccess = null,Object? branches = null,}) {
  return _then(_AuthUserDto(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,loginId: null == loginId ? _self.loginId : loginId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,userType: null == userType ? _self.userType : userType // ignore: cast_nullable_to_non_nullable
as String,empId: freezed == empId ? _self.empId : empId // ignore: cast_nullable_to_non_nullable
as int?,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as int,branchName: freezed == branchName ? _self.branchName : branchName // ignore: cast_nullable_to_non_nullable
as String?,timeZone: freezed == timeZone ? _self.timeZone : timeZone // ignore: cast_nullable_to_non_nullable
as String?,orgCount: freezed == orgCount ? _self.orgCount : orgCount // ignore: cast_nullable_to_non_nullable
as int?,transactionAccess: null == transactionAccess ? _self.transactionAccess : transactionAccess // ignore: cast_nullable_to_non_nullable
as bool,reportAccess: null == reportAccess ? _self.reportAccess : reportAccess // ignore: cast_nullable_to_non_nullable
as bool,branches: null == branches ? _self._branches : branches // ignore: cast_nullable_to_non_nullable
as List<AuthBranchDto>,
  ));
}


}


/// @nodoc
mixin _$LoginResponseDto {

 String get tokenType; String get accessToken; int get expiresIn; DateTime get accessTokenExpiresAtUtc; String get refreshToken; DateTime get refreshTokenExpiresAtUtc; AuthUserDto get user;
/// Create a copy of LoginResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginResponseDtoCopyWith<LoginResponseDto> get copyWith => _$LoginResponseDtoCopyWithImpl<LoginResponseDto>(this as LoginResponseDto, _$identity);

  /// Serializes this LoginResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginResponseDto&&(identical(other.tokenType, tokenType) || other.tokenType == tokenType)&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn)&&(identical(other.accessTokenExpiresAtUtc, accessTokenExpiresAtUtc) || other.accessTokenExpiresAtUtc == accessTokenExpiresAtUtc)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.refreshTokenExpiresAtUtc, refreshTokenExpiresAtUtc) || other.refreshTokenExpiresAtUtc == refreshTokenExpiresAtUtc)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tokenType,accessToken,expiresIn,accessTokenExpiresAtUtc,refreshToken,refreshTokenExpiresAtUtc,user);

@override
String toString() {
  return 'LoginResponseDto(tokenType: $tokenType, accessToken: $accessToken, expiresIn: $expiresIn, accessTokenExpiresAtUtc: $accessTokenExpiresAtUtc, refreshToken: $refreshToken, refreshTokenExpiresAtUtc: $refreshTokenExpiresAtUtc, user: $user)';
}


}

/// @nodoc
abstract mixin class $LoginResponseDtoCopyWith<$Res>  {
  factory $LoginResponseDtoCopyWith(LoginResponseDto value, $Res Function(LoginResponseDto) _then) = _$LoginResponseDtoCopyWithImpl;
@useResult
$Res call({
 String tokenType, String accessToken, int expiresIn, DateTime accessTokenExpiresAtUtc, String refreshToken, DateTime refreshTokenExpiresAtUtc, AuthUserDto user
});


$AuthUserDtoCopyWith<$Res> get user;

}
/// @nodoc
class _$LoginResponseDtoCopyWithImpl<$Res>
    implements $LoginResponseDtoCopyWith<$Res> {
  _$LoginResponseDtoCopyWithImpl(this._self, this._then);

  final LoginResponseDto _self;
  final $Res Function(LoginResponseDto) _then;

/// Create a copy of LoginResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tokenType = null,Object? accessToken = null,Object? expiresIn = null,Object? accessTokenExpiresAtUtc = null,Object? refreshToken = null,Object? refreshTokenExpiresAtUtc = null,Object? user = null,}) {
  return _then(_self.copyWith(
tokenType: null == tokenType ? _self.tokenType : tokenType // ignore: cast_nullable_to_non_nullable
as String,accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,accessTokenExpiresAtUtc: null == accessTokenExpiresAtUtc ? _self.accessTokenExpiresAtUtc : accessTokenExpiresAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,refreshTokenExpiresAtUtc: null == refreshTokenExpiresAtUtc ? _self.refreshTokenExpiresAtUtc : refreshTokenExpiresAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as AuthUserDto,
  ));
}
/// Create a copy of LoginResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthUserDtoCopyWith<$Res> get user {
  
  return $AuthUserDtoCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [LoginResponseDto].
extension LoginResponseDtoPatterns on LoginResponseDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginResponseDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _LoginResponseDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _LoginResponseDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String tokenType,  String accessToken,  int expiresIn,  DateTime accessTokenExpiresAtUtc,  String refreshToken,  DateTime refreshTokenExpiresAtUtc,  AuthUserDto user)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginResponseDto() when $default != null:
return $default(_that.tokenType,_that.accessToken,_that.expiresIn,_that.accessTokenExpiresAtUtc,_that.refreshToken,_that.refreshTokenExpiresAtUtc,_that.user);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String tokenType,  String accessToken,  int expiresIn,  DateTime accessTokenExpiresAtUtc,  String refreshToken,  DateTime refreshTokenExpiresAtUtc,  AuthUserDto user)  $default,) {final _that = this;
switch (_that) {
case _LoginResponseDto():
return $default(_that.tokenType,_that.accessToken,_that.expiresIn,_that.accessTokenExpiresAtUtc,_that.refreshToken,_that.refreshTokenExpiresAtUtc,_that.user);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String tokenType,  String accessToken,  int expiresIn,  DateTime accessTokenExpiresAtUtc,  String refreshToken,  DateTime refreshTokenExpiresAtUtc,  AuthUserDto user)?  $default,) {final _that = this;
switch (_that) {
case _LoginResponseDto() when $default != null:
return $default(_that.tokenType,_that.accessToken,_that.expiresIn,_that.accessTokenExpiresAtUtc,_that.refreshToken,_that.refreshTokenExpiresAtUtc,_that.user);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoginResponseDto implements LoginResponseDto {
  const _LoginResponseDto({this.tokenType = 'Bearer', required this.accessToken, required this.expiresIn, required this.accessTokenExpiresAtUtc, required this.refreshToken, required this.refreshTokenExpiresAtUtc, required this.user});
  factory _LoginResponseDto.fromJson(Map<String, dynamic> json) => _$LoginResponseDtoFromJson(json);

@override@JsonKey() final  String tokenType;
@override final  String accessToken;
@override final  int expiresIn;
@override final  DateTime accessTokenExpiresAtUtc;
@override final  String refreshToken;
@override final  DateTime refreshTokenExpiresAtUtc;
@override final  AuthUserDto user;

/// Create a copy of LoginResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginResponseDtoCopyWith<_LoginResponseDto> get copyWith => __$LoginResponseDtoCopyWithImpl<_LoginResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoginResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginResponseDto&&(identical(other.tokenType, tokenType) || other.tokenType == tokenType)&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn)&&(identical(other.accessTokenExpiresAtUtc, accessTokenExpiresAtUtc) || other.accessTokenExpiresAtUtc == accessTokenExpiresAtUtc)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.refreshTokenExpiresAtUtc, refreshTokenExpiresAtUtc) || other.refreshTokenExpiresAtUtc == refreshTokenExpiresAtUtc)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tokenType,accessToken,expiresIn,accessTokenExpiresAtUtc,refreshToken,refreshTokenExpiresAtUtc,user);

@override
String toString() {
  return 'LoginResponseDto(tokenType: $tokenType, accessToken: $accessToken, expiresIn: $expiresIn, accessTokenExpiresAtUtc: $accessTokenExpiresAtUtc, refreshToken: $refreshToken, refreshTokenExpiresAtUtc: $refreshTokenExpiresAtUtc, user: $user)';
}


}

/// @nodoc
abstract mixin class _$LoginResponseDtoCopyWith<$Res> implements $LoginResponseDtoCopyWith<$Res> {
  factory _$LoginResponseDtoCopyWith(_LoginResponseDto value, $Res Function(_LoginResponseDto) _then) = __$LoginResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 String tokenType, String accessToken, int expiresIn, DateTime accessTokenExpiresAtUtc, String refreshToken, DateTime refreshTokenExpiresAtUtc, AuthUserDto user
});


@override $AuthUserDtoCopyWith<$Res> get user;

}
/// @nodoc
class __$LoginResponseDtoCopyWithImpl<$Res>
    implements _$LoginResponseDtoCopyWith<$Res> {
  __$LoginResponseDtoCopyWithImpl(this._self, this._then);

  final _LoginResponseDto _self;
  final $Res Function(_LoginResponseDto) _then;

/// Create a copy of LoginResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tokenType = null,Object? accessToken = null,Object? expiresIn = null,Object? accessTokenExpiresAtUtc = null,Object? refreshToken = null,Object? refreshTokenExpiresAtUtc = null,Object? user = null,}) {
  return _then(_LoginResponseDto(
tokenType: null == tokenType ? _self.tokenType : tokenType // ignore: cast_nullable_to_non_nullable
as String,accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,accessTokenExpiresAtUtc: null == accessTokenExpiresAtUtc ? _self.accessTokenExpiresAtUtc : accessTokenExpiresAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,refreshTokenExpiresAtUtc: null == refreshTokenExpiresAtUtc ? _self.refreshTokenExpiresAtUtc : refreshTokenExpiresAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as AuthUserDto,
  ));
}

/// Create a copy of LoginResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthUserDtoCopyWith<$Res> get user {
  
  return $AuthUserDtoCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on
