using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Shapes;
using Microsoft.Phone.Controls;
using System.IO.IsolatedStorage;
using System.Windows.Navigation;

namespace PocketPiglet
{
    public partial class PuzzlePage : PhoneApplicationPage
    {
        public PuzzlePage()
        {
            InitializeComponent();
        }

        private void ImageMediumLevel_MouseLeftButtonDown(object sender, MouseButtonEventArgs e)
        {
            NavigationService.Navigate(new Uri("/PuzzleSelectionBackgroundPage.xaml?typeLevel=medium", UriKind.Relative));
        }

        private void ImageHardLevel_MouseLeftButtonDown(object sender, MouseButtonEventArgs e)
        {
            NavigationService.Navigate(new Uri("/PuzzleSelectionBackgroundPage.xaml?typeLevel=hard", UriKind.Relative));
        }

        protected override void OnNavigatingFrom(NavigatingCancelEventArgs e)
        {
            base.OnNavigatingFrom(e);
            IsolatedStorageSettings.ApplicationSettings["AnimationPigletPlay"] = "";
            IsolatedStorageSettings.ApplicationSettings.Save();
        }

    }
}