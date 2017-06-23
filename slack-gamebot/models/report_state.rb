class ReportState
  include Ruby::Enum

  define :PROPOSED, 'proposed'
  define :CONFIRMED, 'confirmed'
  define :CONTESTED, 'contested'
  define :CANCELLED, 'cancelled'
end
