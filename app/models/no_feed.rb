class NoFeed < Feed
  # Represents anything subscribed to that is not a valid feed.
  validate do
    errors[:base] << 'Not a valid feed format.'
  end
end
