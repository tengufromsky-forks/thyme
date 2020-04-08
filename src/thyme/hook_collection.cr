require "../thyme"
require "toml"

class Thyme::HookCollection
  @hooks : Hash(HookEvent, Array(Hook)) = Hash.zip(
    HookEvent.values,
    HookEvent.values.map { Array(Thyme::Hook).new }
  )

  def initialize
  end

  def initialize(hooks : Array(Hook))
    hooks.each do |hook|
      hook.events.each do |event|
        @hooks[event] << hook
      end
    end
  end

  def before(hooks_args)
    call(HookEvent::Before, hooks_args)
  end

  def before_break(hooks_args)
    call(HookEvent::BeforeBreak, hooks_args)
  end

  def before_all(hooks_args)
    call(HookEvent::BeforeAll, hooks_args)
  end

  def after(hooks_args)
    call(HookEvent::After, hooks_args)
  end

  def after_break(hooks_args)
    call(HookEvent::AfterBreak, hooks_args)
  end

  def after_all(hooks_args)
    call(HookEvent::AfterAll, hooks_args)
  end

  private def call(event : HookEvent, hooks_args : NamedTuple)
    @hooks[event].each(&.call(hooks_args))
  end

  def self.parse(hooks : TOML::Type)
    self.new(
      hooks.as(TOML::Table).map do |key, value|
        Hook.parse(key.as(String), value.as(TOML::Table))
      end
    )
  rescue TypeCastError
    raise Error.new("Invalid value for `hooks` in `#{Config::THYMERC_FILE}`")
  end
end