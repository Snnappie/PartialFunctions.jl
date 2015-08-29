################################################################################
# The author disclaims copyright to this source code.  In place of             #
# a legal notice, here is the author's adaptation to the sqlite3 blessing:     #
#                                                                              #
# May you do good and not evil.                                                #
# May you find forgiveness for yourself and forgive others.                    #
# May you share freely, never taking more than you give.                       #
#                                                                              #
# May you love the Lord your God with all your heart,                          #
# with all your soul,                                                          #
# and with all your mind.                                                      #
################################################################################

module PartialFunction

export @partial,
       @pf



macro partial(body)
  if body.head == :tuple
    body = body.args[1]
  end
  local _pos = filter(x -> x != -1, [ body.args[i] == :_ ? i : -1 for i in 1:length(body.args) ])
  local args = [symbol("a", i) for i in 1:count(x -> x == :_, body.args) ]
  local j = 1
  for i in _pos
    body.args[i] = args[j]
    j += 1
  end

  # It seemed simply impossible to write this in a less awkward way.
  # I could not define an anonymous function with arguments embedded into it
  local f = :(function()
    (($(body.args[1]))($(body.args[2:end]...)))
  end)
  f.args[1].args = args
  esc(f)
end

### Convenience for @partial
macro pf(body)
  esc(:(@partial($body)))
end


# Examples:
# Defining inverse in terms of division:
# inverse = @pf (1 / _)
# mapping byte arrays to hex strings
# map(@pf(hex(_, 2)), bytes)
end  # module PartialFunction
