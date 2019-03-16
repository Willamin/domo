require "colorize"

enum Previous
  None
  Type
  Declaration
  Or
  MemberDeclaration
  Member
  Access
end

class Domo::Parser
  @tokens = Array(String).new
  @types = Set(Type).new

  def initialize(@contents : String); end

  def self.from_file(filename)
    self.new(File.open(filename).gets_to_end)
  end

  def tokenize(verbose = false)
    @tokens = @contents
      .split(/(\#.+\n|\#.+\Z)/)
      .reject(&.starts_with?("#"))
      .reject(&.blank?)
      .join("\n")
      .split(/(\s|\.)/).reject(&.blank?)
      .tap { |t| pp t if verbose }
    self
  end

  def parse(verbose = false)
    machine = Domo::StateMachine(Previous).new(Previous::None)
    [{Previous::None, Previous::Type},
     {Previous::Type, Previous::Declaration},
     {Previous::Declaration, Previous::Type},
     {Previous::Type, Previous::Or},
     {Previous::Or, Previous::Type},
     {Previous::Type, Previous::Type},
     {Previous::Type, Previous::Access},
     {Previous::Access, Previous::Member},
     {Previous::Member, Previous::MemberDeclaration},
     {Previous::MemberDeclaration, Previous::Type},
    ].each { |from, to| machine.add_valid(from, to) }

    previous_token = ""
    type_to_act_on : Type? = nil
    member_to_declare : String? = nil

    @tokens.each_with_index do |token, index|
      if verbose
        print "current token       "; pp token.colorize(:yellow)
        print "current_state       "; pp machine.current_state.colorize(:red)
        print "previous_token      "; pp previous_token.colorize(:magenta)
        print "type_to_act_on      "; puts (type_to_act_on.try(&.name) || "nil").colorize(:blue)
        print "member_to_declare   "; puts (member_to_declare || "nil").colorize(:green)
        puts
        puts
      end

      case token
      when .type?
        case machine.current_state
        when .none?, .type?
          type = Type.new(token)
          @types << type
          machine.next(Previous::Type)
        when .declaration?, .or?
          type = Type.new(token)
          @types << type
          type_to_act_on.try(&.subtypes.add(type))
          machine.next(Previous::Type)
        when .member_declaration?
          type = @types.find(Type.new(token)) { |t| t.name == token }
          @types << type
          type_to_act_on.try { |t| t.members[member_to_declare.not_nil!] = type.not_nil! }
          machine.next(Previous::Type)
        else
          raise "Invalid token: #{token}"
        end
      when .declaration?
        case machine.current_state
        when .type?
          type_to_act_on = @types.find { |t| t.name == previous_token }
          machine.next(Previous::Declaration)
        when .member?
          machine.next(Previous::MemberDeclaration)
        else
          raise "Invalid token: #{token}"
        end
      when .or?
        machine.next(Previous::Or, "Can only use or operator when preceded by a type")
      when .access?
        machine.next(Previous::Access, "Cannot access something other than a type")
        type_to_act_on = @types.find { |t| t.name == previous_token }
      when .member?
        member_to_declare = token
        machine.next(Previous::Member, "Cannot define a member unless preceded by an access token")
      else
        @types.each { |t| puts t }
        raise "Unknown token: #{token}"
      end

      previous_token = token
    end

    self
  end

  def check_for_invalid
    invalid_types = @types.reject(&.valid?)
    if invalid_types.size > 0
      raise "Invalid types provided: #{invalid_types.map(&.name)}"
    end
    self
  end

  def print_structure(io = STDERR)
    @types.each { |t| io.puts(t) }
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
