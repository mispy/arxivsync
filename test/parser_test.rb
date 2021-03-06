require_relative 'test_helper'
require 'minitest/autorun'

require 'arxivsync'

TEST_ROOT = File.dirname(__FILE__)

class TestParser < Minitest::Test
  def test_parser
    archive = ArxivSync::XMLArchive.new(File.join(TEST_ROOT, 'fixtures'))
    tested = 0
    archive.read_metadata do |papers|
      assert_equal papers.count, 1000
      papers.each do |paper|
        if paper.id == '0801.3673'
          assert_equal "N. C. Bacalis", paper.submitter

          assert_equal 1, paper.versions.length
          assert_equal Time.parse("Wed, 23 Jan 2008 21:06:41 GMT"), paper.versions[0].date
          assert_equal "121kb", paper.versions[0].size

          assert_equal "Variational Functionals for Excited States", paper.title
          assert_equal "Naoum C. Bacalis", paper.author_str

          assert_equal ["Naoum C. Bacalis"], paper.authors
          assert_equal ["quant-ph"], paper.categories

          assert_equal "4 pages", paper.comments
          assert_equal "Functionals that have local minima at the excited states of a non degenerate Hamiltonian are presented. Then, improved mutually orthogonal approximants of the ground and the first excited state are reported.", paper.abstract
          tested += 1
        end

        if paper.id == '0801.3720'
          assert_equal paper.submitter, "Xin-Zhong Yan"

          assert_equal paper.versions.length, 2
          assert_equal paper.versions[0].date, Time.parse("Thu, 24 Jan 2008 09:31:59 GMT")
          assert_equal paper.versions[0].size, "56kb"
          assert_equal paper.versions[1].date, Time.parse("Wed, 14 May 2008 02:16:45 GMT")
          assert_equal paper.versions[1].size, "58kb"
          
          assert_equal paper.title, "Weak Localization of Dirac Fermions in Graphene"
          assert_equal ["Xin-Zhong Yan", "C. S. Ting"], paper.authors
          assert_equal ["cond-mat.str-el"], paper.categories
          assert_equal paper.comments, "4 pages, 4 figures"
          assert_equal paper.journal_ref, "PRL 101, 126801 (2008)"
          assert_equal paper.doi, "10.1103/PhysRevLett.101.126801"
          assert_equal paper.abstract, "In the presence of the charged impurities, we study the weak localization (WL) effect by evaluating the quantum interference correction (QIC) to the conductivity of Dirac fermions in graphene. With the inelastic scattering rate due to electron-electron interactions obtained from our previous work, we investigate the dependence of QIC on the carrier concentration, the temperature, the magnetic field and the size of the sample. It is found that WL is present in large size samples at finite carrier doping. Its strength becomes weakened/quenched when the sample size is less than a few microns at low temperatures as studied in the experiments. In the region close to zero doping, the system may become delocalized. The minimum conductivity at low temperature for experimental sample sizes is found to be close to the data."
          tested += 1
        end

        # Ensure we handle TeX special characters
        if paper.id == "0801.3763"
          assert_equal "Dijana Žilić", paper.authors[1]

          # But make sure we didn't try to parse any
          # complex math-- that cannot be unicode
          assert_includes paper.abstract, "[Cu(bpy)$_3$]$_2$[Cr(C$_2$O$_4$)$_3$]NO$_3\\cdot $9H$_2$O"
        end

        # Ensure we parse html entities
        if paper.id == "0801.3778"
          assert_equal "6 pages, 10 figures, to appear in \"Young massive clusters, initial conditions and environments\", typo in author's name corrected", paper.comments
        elsif paper.id == "0801.3789"
          assert_includes paper.abstract, "The addition of this \"conservative noise\" allows"
        end

        # And weird author strings
        if paper.id == "0801.3898"
          assert_equal ["A. Frasca", "Zs. Kovari", "K.G. Strassmeier", "K. Biazzo"], paper.authors
        end

        # And those pesky "and"s
        if paper.id == "0801.3674"
          assert_equal ["Robert H. Brandenberger", "Keshav Dasgupta", "Anne-Christine Davis"], paper.authors
        end
      end
    end

    assert_equal tested, 2
  end
end
