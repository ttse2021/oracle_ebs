#
# Setup the PATH variable
#
ENV=$HOME/.kshrc

# Invoke a local profile if one exists
#
if [ -f $HOME/.profile.local ] ; then . $HOME/.profile.local; fi
