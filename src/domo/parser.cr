require "colorize"

class Domo::Parser
  @tokens = Array(String).new
  @types = Set(Type).new

  def initialize(@contents : String); end

  def self.from_file(filename)
    self.new(File.open(filename).gets_to_end)
  end

  def tokenize(verbose)
    @tokens = @contents
      .split(/(\#.+\n|\#.+\Z)/)
      .reject(&.starts_with?("#"))
      .reject(&.blank?)
      .join("\n")
      .split(/(\s|\.)/).reject(&.blank?)
      .tap { |t| pp t if verbose }
    self
  end

  def parse(verbose)
    previous = :none
    previous_token = ""
    type_to_act_on : Type? = nil
    member_to_declare : String? = nil

    @tokens.each_with_index do |token, index|
      if verbose
        print "current token       "; pp token.colorize(:yellow)
        print "previous            "; pp previous.colorize(:red)
        print "previous_token      "; pp previous_token.colorize(:magenta)
        print "type_to_act_on      "; puts (type_to_act_on.try(&.name) || "nil").colorize(:blue)
        print "member_to_declare   "; puts (member_to_declare || "nil").colorize(:green)
        puts
        puts
      end

      case token
      when .type?
        if previous == :none || previous == :type
          type = Type.new(token)
          @types << type
          previous = :type
        end

        if previous == :declaration || previous == :or
          type = Type.new(token)
          @types << type
          type_to_act_on.try(&.subtypes.add(type))
          previous = :type
        end

        if previous == :member_declaration
          type = @types.find(Type.new(token)) { |t| t.name == token }
          @types << type
          type_to_act_on.try { |t| t.members[member_to_declare.not_nil!] = type.not_nil! }
          previous = :type
        end
      when .declaration?
        if previous == :type
          type_to_act_on = @types.find { |t| t.name == previous_token }
          previous = :declaration
        end

        if previous == :member
          previous = :member_declaration
        end
      when .or?
        if previous != :type
          raise "Can only use or operator when preceded by a type (i=#{index})"
        end
        previous = :or
      when .access?
        if previous != :type
          raise "Cannot access something other than a type (i=#{index})"
        end
        type_to_act_on = @types.find { |t| t.name == previous_token }
        previous = :access
      when .member?
        if previous != :access
          raise "Cannot define a member unless preceded by an access token (i=#{index})"
        end
        member_to_declare = token
        previous = :member
      else
        @types.each { |t| puts t }
        raise "Unknown token: #{token} (i=#{index})"
      end

      previous_token = token
    end

    @types.each { |t| puts t }
    self
  end

  def check_for_invalid
    invalid_types = @types.reject(&.valid?)
    if invalid_types.size > 0
      raise "Invalid types provided: #{invalid_types.map(&.name)}"
    end
  end
end

class Domo::Type
  getter name : String
  getter members = Hash(String, Domo::Type).new
  getter subtypes = Set(Domo::Type).new

  def initialize(@name); end

  def to_s(io)
    io << "#{name}"

    if subtypes.size > 0
      io << " : "
      io << subtypes.map(&.name).join(" | ")
    end

    if members.size > 0
      io << " :: "
      io << members.map { |k, v| ".#{k} : #{v.name}" }.join(", ")
    end
  end

  def valid?
    !(members.size > 0 && subtypes.size > 0)
  end

  def ==(other)
    typeof(other) == typeof(self) && other.name == name
  end

  def_hash(@name)
end
