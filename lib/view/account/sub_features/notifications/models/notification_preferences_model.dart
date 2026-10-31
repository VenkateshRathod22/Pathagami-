class NotificationPreferencesModel {
  // 1. Bookings Mandatory Notifications
  final bool bookingSms;
  final bool bookingWhatsapp;
  final bool bookingEmail;
  final bool bookingPush;

  // 2. Offers & Promotions
  final bool offersSms;
  final bool offersWhatsapp;
  final bool offersEmail;
  final bool offersPush;

  const NotificationPreferencesModel({
    this.bookingSms = true,
    this.bookingWhatsapp = true,
    this.bookingEmail = true,
    this.bookingPush = true,
    this.offersSms = true,
    this.offersWhatsapp = true,
    this.offersEmail = true,
    this.offersPush = true,
  });

  NotificationPreferencesModel copyWith({
    bool? bookingSms,
    bool? bookingWhatsapp,
    bool? bookingEmail,
    bool? bookingPush,
    bool? offersSms,
    bool? offersWhatsapp,
    bool? offersEmail,
    bool? offersPush,
  }) {
    return NotificationPreferencesModel(
      bookingSms: bookingSms ?? this.bookingSms,
      bookingWhatsapp: bookingWhatsapp ?? this.bookingWhatsapp,
      bookingEmail: bookingEmail ?? this.bookingEmail,
      bookingPush: bookingPush ?? this.bookingPush,
      offersSms: offersSms ?? this.offersSms,
      offersWhatsapp: offersWhatsapp ?? this.offersWhatsapp,
      offersEmail: offersEmail ?? this.offersEmail,
      offersPush: offersPush ?? this.offersPush,
    );
  }

  factory NotificationPreferencesModel.fromJson(Map<String, dynamic> json) {
    return NotificationPreferencesModel(
      bookingSms: json['booking_sms'] as bool? ?? true,
      bookingWhatsapp: json['booking_whatsapp'] as bool? ?? true,
      bookingEmail: json['booking_email'] as bool? ?? true,
      bookingPush: json['booking_push'] as bool? ?? true,
      offersSms: json['offers_sms'] as bool? ?? true,
      offersWhatsapp: json['offers_whatsapp'] as bool? ?? true,
      offersEmail: json['offers_email'] as bool? ?? true,
      offersPush: json['offers_push'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking_sms': bookingSms,
      'booking_whatsapp': bookingWhatsapp,
      'booking_email': bookingEmail,
      'booking_push': bookingPush,
      'offers_sms': offersSms,
      'offers_whatsapp': offersWhatsapp,
      'offers_email': offersEmail,
      'offers_push': offersPush,
    };
  }
}
