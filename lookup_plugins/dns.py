# Copyright 2015 Brian Aker
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

import os

__author__ = "Brian Aker <brian@tangent.org>"
__copyright__ = "Copyright 2015 by Brian Aker <brian@tangent.org>"
__license__ = "BSD"

CHECK_FOR_DNS_RESOLVER=False
try:
    import dns.resolver
    from dns.exception import DNSException
    CHECK_FOR_DNS_RESOLVER=True
except ImportError:
    pass

from ansible import utils, errors
from ansible import __version__ as __ansible_version__
class LookupModule (object):
  def __init__(self, basedir=None, **kwargs):
    self.basedir = basedir

  def run(self, terms, inject=None, **kwargs):

    if CHECK_FOR_DNS_RESOLVER == False:
      raise errors.AnsibleError("Cannot resolve IP Addresss: module dns.resolver is not installed")
          
    terms = utils.listify_lookup_plugin_terms(terms, self.basedir, inject)
    ret = []

    if isinstance(terms, basestring):
      terms = [ terms ]

    for term in terms:
      hostname = term.split()[0]
      try:
        answers = dns.resolver.query(hostname, 'A')
        for rdata in answers:
          ret.append(''.join(rdata.to_text()))

      except dns.resolver.NXDOMAIN:
        string = 'NXDOMAIN'
      except dns.resolver.Timeout:
        string = ''
      except dns.exception.DNSException as e:
        raise errors.AnsibleError("dns.resolver unhandled exception", e)

    return ret
