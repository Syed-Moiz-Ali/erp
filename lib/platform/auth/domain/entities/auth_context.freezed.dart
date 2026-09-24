// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_context.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UserAccount {

 String get id; String get displayName; String get email; String? get phone; String? get avatarUrl; String get companyId; PermissionSet get permissions; AccountStatus get status;
/// Create a copy of UserAccount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserAccountCopyWith<UserAccount> get copyWith => _$UserAccountCopyWithImpl<UserAccount>(this as UserAccount, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserAccount&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.permissions, permissions) || other.permissions == permissions)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,id,displayName,email,phone,avatarUrl,companyId,permissions,status);

@override
String toString() {
  return 'UserAccount(id: $id, displayName: $displayName, email: $email, phone: $phone, avatarUrl: $avatarUrl, companyId: $companyId, permissions: $permissions, status: $status)';
}


}

/// @nodoc
abstract mixin class $UserAccountCopyWith<$Res>  {
  factory $UserAccountCopyWith(UserAccount value, $Res Function(UserAccount) _then) = _$UserAccountCopyWithImpl;
@useResult
$Res call({
 String id, String displayName, String email, String? phone, String? avatarUrl, String companyId, PermissionSet permissions, AccountStatus status
});




}
/// @nodoc
class _$UserAccountCopyWithImpl<$Res>
    implements $UserAccountCopyWith<$Res> {
  _$UserAccountCopyWithImpl(this._self, this._then);

  final UserAccount _self;
  final $Res Function(UserAccount) _then;

/// Create a copy of UserAccount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? displayName = null,Object? email = null,Object? phone = freezed,Object? avatarUrl = freezed,Object? companyId = null,Object? permissions = null,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as PermissionSet,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AccountStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [UserAccount].
extension UserAccountPatterns on UserAccount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserAccount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserAccount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserAccount value)  $default,){
final _that = this;
switch (_that) {
case _UserAccount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserAccount value)?  $default,){
final _that = this;
switch (_that) {
case _UserAccount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String displayName,  String email,  String? phone,  String? avatarUrl,  String companyId,  PermissionSet permissions,  AccountStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserAccount() when $default != null:
return $default(_that.id,_that.displayName,_that.email,_that.phone,_that.avatarUrl,_that.companyId,_that.permissions,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String displayName,  String email,  String? phone,  String? avatarUrl,  String companyId,  PermissionSet permissions,  AccountStatus status)  $default,) {final _that = this;
switch (_that) {
case _UserAccount():
return $default(_that.id,_that.displayName,_that.email,_that.phone,_that.avatarUrl,_that.companyId,_that.permissions,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String displayName,  String email,  String? phone,  String? avatarUrl,  String companyId,  PermissionSet permissions,  AccountStatus status)?  $default,) {final _that = this;
switch (_that) {
case _UserAccount() when $default != null:
return $default(_that.id,_that.displayName,_that.email,_that.phone,_that.avatarUrl,_that.companyId,_that.permissions,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _UserAccount implements UserAccount {
  const _UserAccount({required this.id, required this.displayName, required this.email, this.phone, this.avatarUrl, required this.companyId, required this.permissions, required this.status});
  

@override final  String id;
@override final  String displayName;
@override final  String email;
@override final  String? phone;
@override final  String? avatarUrl;
@override final  String companyId;
@override final  PermissionSet permissions;
@override final  AccountStatus status;

/// Create a copy of UserAccount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserAccountCopyWith<_UserAccount> get copyWith => __$UserAccountCopyWithImpl<_UserAccount>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserAccount&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.permissions, permissions) || other.permissions == permissions)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,id,displayName,email,phone,avatarUrl,companyId,permissions,status);

@override
String toString() {
  return 'UserAccount(id: $id, displayName: $displayName, email: $email, phone: $phone, avatarUrl: $avatarUrl, companyId: $companyId, permissions: $permissions, status: $status)';
}


}

/// @nodoc
abstract mixin class _$UserAccountCopyWith<$Res> implements $UserAccountCopyWith<$Res> {
  factory _$UserAccountCopyWith(_UserAccount value, $Res Function(_UserAccount) _then) = __$UserAccountCopyWithImpl;
@override @useResult
$Res call({
 String id, String displayName, String email, String? phone, String? avatarUrl, String companyId, PermissionSet permissions, AccountStatus status
});




}
/// @nodoc
class __$UserAccountCopyWithImpl<$Res>
    implements _$UserAccountCopyWith<$Res> {
  __$UserAccountCopyWithImpl(this._self, this._then);

  final _UserAccount _self;
  final $Res Function(_UserAccount) _then;

/// Create a copy of UserAccount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? displayName = null,Object? email = null,Object? phone = freezed,Object? avatarUrl = freezed,Object? companyId = null,Object? permissions = null,Object? status = null,}) {
  return _then(_UserAccount(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as PermissionSet,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AccountStatus,
  ));
}


}

/// @nodoc
mixin _$CompanyContext {

 String get id; String get name; String? get logoUrl; String get code; String get timezone; String get defaultLocale; Set<String> get enabledModules;
/// Create a copy of CompanyContext
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompanyContextCopyWith<CompanyContext> get copyWith => _$CompanyContextCopyWithImpl<CompanyContext>(this as CompanyContext, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompanyContext&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.code, code) || other.code == code)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.defaultLocale, defaultLocale) || other.defaultLocale == defaultLocale)&&const DeepCollectionEquality().equals(other.enabledModules, enabledModules));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,logoUrl,code,timezone,defaultLocale,const DeepCollectionEquality().hash(enabledModules));

@override
String toString() {
  return 'CompanyContext(id: $id, name: $name, logoUrl: $logoUrl, code: $code, timezone: $timezone, defaultLocale: $defaultLocale, enabledModules: $enabledModules)';
}


}

/// @nodoc
abstract mixin class $CompanyContextCopyWith<$Res>  {
  factory $CompanyContextCopyWith(CompanyContext value, $Res Function(CompanyContext) _then) = _$CompanyContextCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? logoUrl, String code, String timezone, String defaultLocale, Set<String> enabledModules
});




}
/// @nodoc
class _$CompanyContextCopyWithImpl<$Res>
    implements $CompanyContextCopyWith<$Res> {
  _$CompanyContextCopyWithImpl(this._self, this._then);

  final CompanyContext _self;
  final $Res Function(CompanyContext) _then;

/// Create a copy of CompanyContext
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? logoUrl = freezed,Object? code = null,Object? timezone = null,Object? defaultLocale = null,Object? enabledModules = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,defaultLocale: null == defaultLocale ? _self.defaultLocale : defaultLocale // ignore: cast_nullable_to_non_nullable
as String,enabledModules: null == enabledModules ? _self.enabledModules : enabledModules // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [CompanyContext].
extension CompanyContextPatterns on CompanyContext {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompanyContext value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompanyContext() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompanyContext value)  $default,){
final _that = this;
switch (_that) {
case _CompanyContext():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompanyContext value)?  $default,){
final _that = this;
switch (_that) {
case _CompanyContext() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? logoUrl,  String code,  String timezone,  String defaultLocale,  Set<String> enabledModules)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompanyContext() when $default != null:
return $default(_that.id,_that.name,_that.logoUrl,_that.code,_that.timezone,_that.defaultLocale,_that.enabledModules);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? logoUrl,  String code,  String timezone,  String defaultLocale,  Set<String> enabledModules)  $default,) {final _that = this;
switch (_that) {
case _CompanyContext():
return $default(_that.id,_that.name,_that.logoUrl,_that.code,_that.timezone,_that.defaultLocale,_that.enabledModules);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? logoUrl,  String code,  String timezone,  String defaultLocale,  Set<String> enabledModules)?  $default,) {final _that = this;
switch (_that) {
case _CompanyContext() when $default != null:
return $default(_that.id,_that.name,_that.logoUrl,_that.code,_that.timezone,_that.defaultLocale,_that.enabledModules);case _:
  return null;

}
}

}

/// @nodoc


class _CompanyContext implements CompanyContext {
  const _CompanyContext({required this.id, required this.name, this.logoUrl, required this.code, required this.timezone, required this.defaultLocale, required final  Set<String> enabledModules}): _enabledModules = enabledModules;
  

@override final  String id;
@override final  String name;
@override final  String? logoUrl;
@override final  String code;
@override final  String timezone;
@override final  String defaultLocale;
 final  Set<String> _enabledModules;
@override Set<String> get enabledModules {
  if (_enabledModules is EqualUnmodifiableSetView) return _enabledModules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_enabledModules);
}


/// Create a copy of CompanyContext
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompanyContextCopyWith<_CompanyContext> get copyWith => __$CompanyContextCopyWithImpl<_CompanyContext>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompanyContext&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.code, code) || other.code == code)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.defaultLocale, defaultLocale) || other.defaultLocale == defaultLocale)&&const DeepCollectionEquality().equals(other._enabledModules, _enabledModules));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,logoUrl,code,timezone,defaultLocale,const DeepCollectionEquality().hash(_enabledModules));

@override
String toString() {
  return 'CompanyContext(id: $id, name: $name, logoUrl: $logoUrl, code: $code, timezone: $timezone, defaultLocale: $defaultLocale, enabledModules: $enabledModules)';
}


}

/// @nodoc
abstract mixin class _$CompanyContextCopyWith<$Res> implements $CompanyContextCopyWith<$Res> {
  factory _$CompanyContextCopyWith(_CompanyContext value, $Res Function(_CompanyContext) _then) = __$CompanyContextCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? logoUrl, String code, String timezone, String defaultLocale, Set<String> enabledModules
});




}
/// @nodoc
class __$CompanyContextCopyWithImpl<$Res>
    implements _$CompanyContextCopyWith<$Res> {
  __$CompanyContextCopyWithImpl(this._self, this._then);

  final _CompanyContext _self;
  final $Res Function(_CompanyContext) _then;

/// Create a copy of CompanyContext
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? logoUrl = freezed,Object? code = null,Object? timezone = null,Object? defaultLocale = null,Object? enabledModules = null,}) {
  return _then(_CompanyContext(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,defaultLocale: null == defaultLocale ? _self.defaultLocale : defaultLocale // ignore: cast_nullable_to_non_nullable
as String,enabledModules: null == enabledModules ? _self._enabledModules : enabledModules // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}


}

/// @nodoc
mixin _$EmployeeReference {

 String get id; String get userAccountId; String get companyId;
/// Create a copy of EmployeeReference
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmployeeReferenceCopyWith<EmployeeReference> get copyWith => _$EmployeeReferenceCopyWithImpl<EmployeeReference>(this as EmployeeReference, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmployeeReference&&(identical(other.id, id) || other.id == id)&&(identical(other.userAccountId, userAccountId) || other.userAccountId == userAccountId)&&(identical(other.companyId, companyId) || other.companyId == companyId));
}


@override
int get hashCode => Object.hash(runtimeType,id,userAccountId,companyId);

@override
String toString() {
  return 'EmployeeReference(id: $id, userAccountId: $userAccountId, companyId: $companyId)';
}


}

/// @nodoc
abstract mixin class $EmployeeReferenceCopyWith<$Res>  {
  factory $EmployeeReferenceCopyWith(EmployeeReference value, $Res Function(EmployeeReference) _then) = _$EmployeeReferenceCopyWithImpl;
@useResult
$Res call({
 String id, String userAccountId, String companyId
});




}
/// @nodoc
class _$EmployeeReferenceCopyWithImpl<$Res>
    implements $EmployeeReferenceCopyWith<$Res> {
  _$EmployeeReferenceCopyWithImpl(this._self, this._then);

  final EmployeeReference _self;
  final $Res Function(EmployeeReference) _then;

/// Create a copy of EmployeeReference
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userAccountId = null,Object? companyId = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userAccountId: null == userAccountId ? _self.userAccountId : userAccountId // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [EmployeeReference].
extension EmployeeReferencePatterns on EmployeeReference {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmployeeReference value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmployeeReference() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmployeeReference value)  $default,){
final _that = this;
switch (_that) {
case _EmployeeReference():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmployeeReference value)?  $default,){
final _that = this;
switch (_that) {
case _EmployeeReference() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userAccountId,  String companyId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmployeeReference() when $default != null:
return $default(_that.id,_that.userAccountId,_that.companyId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userAccountId,  String companyId)  $default,) {final _that = this;
switch (_that) {
case _EmployeeReference():
return $default(_that.id,_that.userAccountId,_that.companyId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userAccountId,  String companyId)?  $default,) {final _that = this;
switch (_that) {
case _EmployeeReference() when $default != null:
return $default(_that.id,_that.userAccountId,_that.companyId);case _:
  return null;

}
}

}

/// @nodoc


class _EmployeeReference implements EmployeeReference {
  const _EmployeeReference({required this.id, required this.userAccountId, required this.companyId});
  

@override final  String id;
@override final  String userAccountId;
@override final  String companyId;

/// Create a copy of EmployeeReference
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmployeeReferenceCopyWith<_EmployeeReference> get copyWith => __$EmployeeReferenceCopyWithImpl<_EmployeeReference>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmployeeReference&&(identical(other.id, id) || other.id == id)&&(identical(other.userAccountId, userAccountId) || other.userAccountId == userAccountId)&&(identical(other.companyId, companyId) || other.companyId == companyId));
}


@override
int get hashCode => Object.hash(runtimeType,id,userAccountId,companyId);

@override
String toString() {
  return 'EmployeeReference(id: $id, userAccountId: $userAccountId, companyId: $companyId)';
}


}

/// @nodoc
abstract mixin class _$EmployeeReferenceCopyWith<$Res> implements $EmployeeReferenceCopyWith<$Res> {
  factory _$EmployeeReferenceCopyWith(_EmployeeReference value, $Res Function(_EmployeeReference) _then) = __$EmployeeReferenceCopyWithImpl;
@override @useResult
$Res call({
 String id, String userAccountId, String companyId
});




}
/// @nodoc
class __$EmployeeReferenceCopyWithImpl<$Res>
    implements _$EmployeeReferenceCopyWith<$Res> {
  __$EmployeeReferenceCopyWithImpl(this._self, this._then);

  final _EmployeeReference _self;
  final $Res Function(_EmployeeReference) _then;

/// Create a copy of EmployeeReference
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userAccountId = null,Object? companyId = null,}) {
  return _then(_EmployeeReference(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userAccountId: null == userAccountId ? _self.userAccountId : userAccountId // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$AuthContext {

 UserAccount get user; CompanyContext get company; EmployeeReference? get employeeReference; Map<String, String> get settings;
/// Create a copy of AuthContext
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthContextCopyWith<AuthContext> get copyWith => _$AuthContextCopyWithImpl<AuthContext>(this as AuthContext, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthContext&&(identical(other.user, user) || other.user == user)&&(identical(other.company, company) || other.company == company)&&(identical(other.employeeReference, employeeReference) || other.employeeReference == employeeReference)&&const DeepCollectionEquality().equals(other.settings, settings));
}


@override
int get hashCode => Object.hash(runtimeType,user,company,employeeReference,const DeepCollectionEquality().hash(settings));

@override
String toString() {
  return 'AuthContext(user: $user, company: $company, employeeReference: $employeeReference, settings: $settings)';
}


}

/// @nodoc
abstract mixin class $AuthContextCopyWith<$Res>  {
  factory $AuthContextCopyWith(AuthContext value, $Res Function(AuthContext) _then) = _$AuthContextCopyWithImpl;
@useResult
$Res call({
 UserAccount user, CompanyContext company, EmployeeReference? employeeReference, Map<String, String> settings
});


$UserAccountCopyWith<$Res> get user;$CompanyContextCopyWith<$Res> get company;$EmployeeReferenceCopyWith<$Res>? get employeeReference;

}
/// @nodoc
class _$AuthContextCopyWithImpl<$Res>
    implements $AuthContextCopyWith<$Res> {
  _$AuthContextCopyWithImpl(this._self, this._then);

  final AuthContext _self;
  final $Res Function(AuthContext) _then;

/// Create a copy of AuthContext
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? user = null,Object? company = null,Object? employeeReference = freezed,Object? settings = null,}) {
  return _then(_self.copyWith(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserAccount,company: null == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as CompanyContext,employeeReference: freezed == employeeReference ? _self.employeeReference : employeeReference // ignore: cast_nullable_to_non_nullable
as EmployeeReference?,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}
/// Create a copy of AuthContext
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserAccountCopyWith<$Res> get user {
  
  return $UserAccountCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of AuthContext
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompanyContextCopyWith<$Res> get company {
  
  return $CompanyContextCopyWith<$Res>(_self.company, (value) {
    return _then(_self.copyWith(company: value));
  });
}/// Create a copy of AuthContext
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EmployeeReferenceCopyWith<$Res>? get employeeReference {
    if (_self.employeeReference == null) {
    return null;
  }

  return $EmployeeReferenceCopyWith<$Res>(_self.employeeReference!, (value) {
    return _then(_self.copyWith(employeeReference: value));
  });
}
}


/// Adds pattern-matching-related methods to [AuthContext].
extension AuthContextPatterns on AuthContext {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthContext value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthContext() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthContext value)  $default,){
final _that = this;
switch (_that) {
case _AuthContext():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthContext value)?  $default,){
final _that = this;
switch (_that) {
case _AuthContext() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UserAccount user,  CompanyContext company,  EmployeeReference? employeeReference,  Map<String, String> settings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthContext() when $default != null:
return $default(_that.user,_that.company,_that.employeeReference,_that.settings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UserAccount user,  CompanyContext company,  EmployeeReference? employeeReference,  Map<String, String> settings)  $default,) {final _that = this;
switch (_that) {
case _AuthContext():
return $default(_that.user,_that.company,_that.employeeReference,_that.settings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UserAccount user,  CompanyContext company,  EmployeeReference? employeeReference,  Map<String, String> settings)?  $default,) {final _that = this;
switch (_that) {
case _AuthContext() when $default != null:
return $default(_that.user,_that.company,_that.employeeReference,_that.settings);case _:
  return null;

}
}

}

/// @nodoc


class _AuthContext implements AuthContext {
  const _AuthContext({required this.user, required this.company, this.employeeReference, final  Map<String, String> settings = const {}}): _settings = settings;
  

@override final  UserAccount user;
@override final  CompanyContext company;
@override final  EmployeeReference? employeeReference;
 final  Map<String, String> _settings;
@override@JsonKey() Map<String, String> get settings {
  if (_settings is EqualUnmodifiableMapView) return _settings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_settings);
}


/// Create a copy of AuthContext
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthContextCopyWith<_AuthContext> get copyWith => __$AuthContextCopyWithImpl<_AuthContext>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthContext&&(identical(other.user, user) || other.user == user)&&(identical(other.company, company) || other.company == company)&&(identical(other.employeeReference, employeeReference) || other.employeeReference == employeeReference)&&const DeepCollectionEquality().equals(other._settings, _settings));
}


@override
int get hashCode => Object.hash(runtimeType,user,company,employeeReference,const DeepCollectionEquality().hash(_settings));

@override
String toString() {
  return 'AuthContext(user: $user, company: $company, employeeReference: $employeeReference, settings: $settings)';
}


}

/// @nodoc
abstract mixin class _$AuthContextCopyWith<$Res> implements $AuthContextCopyWith<$Res> {
  factory _$AuthContextCopyWith(_AuthContext value, $Res Function(_AuthContext) _then) = __$AuthContextCopyWithImpl;
@override @useResult
$Res call({
 UserAccount user, CompanyContext company, EmployeeReference? employeeReference, Map<String, String> settings
});


@override $UserAccountCopyWith<$Res> get user;@override $CompanyContextCopyWith<$Res> get company;@override $EmployeeReferenceCopyWith<$Res>? get employeeReference;

}
/// @nodoc
class __$AuthContextCopyWithImpl<$Res>
    implements _$AuthContextCopyWith<$Res> {
  __$AuthContextCopyWithImpl(this._self, this._then);

  final _AuthContext _self;
  final $Res Function(_AuthContext) _then;

/// Create a copy of AuthContext
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? user = null,Object? company = null,Object? employeeReference = freezed,Object? settings = null,}) {
  return _then(_AuthContext(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserAccount,company: null == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as CompanyContext,employeeReference: freezed == employeeReference ? _self.employeeReference : employeeReference // ignore: cast_nullable_to_non_nullable
as EmployeeReference?,settings: null == settings ? _self._settings : settings // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

/// Create a copy of AuthContext
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserAccountCopyWith<$Res> get user {
  
  return $UserAccountCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of AuthContext
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompanyContextCopyWith<$Res> get company {
  
  return $CompanyContextCopyWith<$Res>(_self.company, (value) {
    return _then(_self.copyWith(company: value));
  });
}/// Create a copy of AuthContext
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EmployeeReferenceCopyWith<$Res>? get employeeReference {
    if (_self.employeeReference == null) {
    return null;
  }

  return $EmployeeReferenceCopyWith<$Res>(_self.employeeReference!, (value) {
    return _then(_self.copyWith(employeeReference: value));
  });
}
}

// dart format on
