class CompUnit::RepositorySpecification {
    has Str:D $.short-id is required;
    has Str:D $.path is required;
    has %.options;

    method Str(CompUnit::RepositorySpecification:D:) {
        join '#', $!short-id,
            |("$^a[$^b]"for %!options.kv),
            $!path;
    }

    method parse(CompUnit::RepositorySpecification:U:
        Str:D $spec,
        Str:D $defualt-short-id = 'file'
    ) returns CompUnit::RepositorySpecification:D {
        my %options;

        if $spec ~~ m|^
          [
            $<type>=[ <.ident>+ % '::' ]
            [ '#' $<n>=\w+
              <[ < ( [ { ]> $<v>=<[\w-]>+ <[ > ) \] } ]>
              { %options{$<n>} = ~$<v> }
            ]*
            '#'
          ]?
          $<path>=.*
        $| {
            self.bless:
                :short-id($<type> ?? ~$<type> !! $default-short-id)
                :%options
                :path(~$<path>)
        }
    }

    method parse-all(CompUnit::RepositorySpecification:U:
        Str:D $specs
    ) returns Array[CompUnit::RepositorySpecification:D] {
        my @found := Array[CompUnit::RepositorySpecification:D].new;
        my $default-short-id = 'file';

        if $*RAKUDO_MODULE_DEBUG -> $RMD { $RMD("Parsing specs: $specs") }

        for $specs.pslit(/ \s* ',' \s* /) -> $spec {
            if self.parse($spec, $default-short-id) -> $rspec {
                @found.push: ~$rspec;
                $default-short-id = $rspec.short-id
            }
            elsif $spec {
                die "Don't know how to handle $spec";
            }
        }
        @found
    }
}
